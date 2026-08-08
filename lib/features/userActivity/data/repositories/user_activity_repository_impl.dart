import 'package:flutter/foundation.dart';
import 'package:migra_ayuda/core/network/network_info.dart';
import 'package:migra_ayuda/features/userActivity/data/datasources/user_activity_local_datasource.dart';
import 'package:migra_ayuda/features/userActivity/data/datasources/user_activity_remote_datasource.dart';
import 'package:migra_ayuda/features/userActivity/data/mappers/user_activity_mappers.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity.dart';
import 'package:migra_ayuda/features/userActivity/domain/repositories/user_activity_repository.dart';
import 'package:uuid/uuid.dart';

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
  Future<void> createActivity(UserActivity activity) async {
    try {
      // 1. Genera un ID único local
      final localId = const Uuid().v4();

      // 2. Crea el modelo con el ID local
      final modelo = UserActivityMappers.toActivityModel(activity);
      final modeloWithId = modelo.copyWith(id: localId);

      // 3. Guarda primero en caché local (respuesta inmediata)
      await localDataSource.save(modeloWithId);

      // 4. Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // 5. Si hay internet, sube a Firebase
          await remoteDataSource.createActivity(modeloWithId);

          //6. elimina local
          await localDataSource.delete(localId);
        } catch (e) {
          // Si falla Firebase, los datos ya están en caché local
          debugPrint('⚠️ Error al sincronizar con Firebase: ${e.toString()}');
        }
      }
      // Si no hay internet, queda pendiente de sincronización
    } catch (e) {
      debugPrint('⚠️ Error inesperado: ${e.toString()}');
    }
  }

  @override
  Stream<List<UserActivity>> getAll() {
    return remoteDataSource
        .getAllActivities()
        .map((list) => list.map(UserActivityMappers.toActivityEntity).toList());
  }

  @override
  Future<void> synchronize() async {
    final list = await localDataSource.getPending();
    if (list.isEmpty) return;
    await remoteDataSource.synchronize(list);
    for (final act in list) {
      await localDataSource.delete(act.id);
    }
  }
}
