import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:migra_ayuda/core/network/network_info.dart';
import 'package:migra_ayuda/features/userActivity/data/datasources/user_activity_local_datasource.dart';
import 'package:migra_ayuda/features/userActivity/data/datasources/user_activity_remote_datasource.dart';
import 'package:migra_ayuda/features/userActivity/data/models/user_activity_model.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda/features/userActivity/domain/failures/activity_failure.dart';
import 'package:migra_ayuda/features/userActivity/domain/repositories/user_activity_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementación del repositorio de user activities con estrategia Offline-First
///
/// Esta implementación permite:
/// - Crear actividades offline (se guardan localmente)
/// - Sincronizar actividades pendientes cuando hay conexión
///
/// Mejoras implementadas:
/// - Operaciones atómicas para prevenir duplicados por race conditions
/// - Idempotencia en Firebase para prevenir duplicados por reintentos
/// - Manejo de errores tipados con ActivityFailure
/// - Reporte de fallos parciales en sincronización
class UserActivityRepositoryImpl implements UserActivityRepository {
  final UserActivityRemoteDataSource remoteDataSource;
  final UserActivityLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserActivityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<ActivityFailure, Unit>> createActivity(
      UserActivityEntity activity) async {
    try {
      // 1. Genera un ID único local
      final localId = const Uuid().v4();

      // 2. Crea el modelo con el ID local
      final modelo = UserActivityModel(
        id: localId,
        idUser: activity.idUser,
        accion: activity.accion,
        createdAt: activity.createdAt,
        isSynced: false, // Inicialmente no sincronizada
      );

      // 3. Guarda primero en caché local (respuesta inmediata)
      await localDataSource.cacheActivity(modelo);

      // 4. Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // 5. Si hay internet, sube a Firebase
          await remoteDataSource.createActivity(modelo);

          //6. elimina local
          await localDataSource.deleteLocalRecord(localId);
        } on ServerException catch (e) {
          // Si falla Firebase, los datos ya están en caché local
          debugPrint('⚠️ Error al sincronizar con Firebase: ${e.message}');
          return right(unit); // Éxito parcial (guardado localmente)
        }
      }
      // Si no hay internet, queda pendiente de sincronización

      return right(unit);
    } on CacheException catch (e) {
      return left(CacheFailure(e.message));
    } catch (e) {
      return left(CacheFailure('Error inesperado: ${e.toString()}'));
    }
  }

  /// Sincroniza las actividades pendientes con Firebase
  @override
  Future<Either<ActivityFailure, Unit>> syncPendingActivities() async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) return left(const NetworkFailure());

      final pendingActivities = await localDataSource.getPendingActivities();
      if (pendingActivities.isEmpty) return right(unit);

      int failedCount = 0;

      for (final activity in pendingActivities) {
        try {
          // 1. Sube a Firebase
          await remoteDataSource.createActivity(activity);

          // 2. ✅ Elimina de local si subió correctamente
          await localDataSource.deleteLocalRecord(activity.id);
        } catch (e) {
          failedCount++;
          debugPrint('⚠️ Error al sincronizar actividad ${activity.id}: $e');
          // Continúa con las demás
        }
      }

      // Si al menos una falló, reporta fallo parcial
      if (failedCount > 0) {
        return left(SyncFailure(failedCount));
      }

      return right(unit);
    } on CacheException catch (e) {
      return left(CacheFailure(e.message));
    } catch (e) {
      return left(CacheFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ActivityFailure, Unit>> getAllActivity() {
    // Este método no está implementado según los requisitos
    // Solo se necesita crear y sincronizar
    throw UnimplementedError(
        'getAllActivity no es requerido para esta funcionalidad');
  }
}
