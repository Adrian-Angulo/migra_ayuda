import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/network/network_info.dart';
import 'package:migra_ayuda/core/sync/sync_result.dart';
import 'package:migra_ayuda/features/entities/domain/usecases/sync_all_entities_usecase.dart';
import 'package:migra_ayuda/features/reviews/domain/usecases/sync_all_reviews_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio centralizado para sincronización inicial de TODAS las features
///
/// Coordina la descarga de todos los datos desde Firebase al iniciar la app:
/// - Entidades
/// - Reviews
/// - (Futuro: Imágenes, usuarios, etc.)
class InitialSyncService {
  final NetworkInfo networkInfo;
  final SyncAllEntitiesUsecase syncEntitiesUsecase;
  final SyncAllReviewsUsecase syncReviewsUsecase;
  final SharedPreferences prefs;

  // Keys para SharedPreferences
  static const String _keySyncCompleted = 'initial_sync_completed';
  static const String _keyLastSyncDate = 'last_sync_date';

  InitialSyncService({
    required this.networkInfo,
    required this.syncEntitiesUsecase,
    required this.syncReviewsUsecase,
    required this.prefs,
  });

  /// Sincroniza TODO desde Firebase
  ///
  /// Flujo:
  /// 1. Verifica conexión a internet
  /// 2. Sincroniza entidades
  /// 3. Sincroniza reviews
  /// 4. Marca como sincronizado
  ///
  /// Retorna [Right(SyncResult)] si la sincronización fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, SyncResult>> syncAll() async {
    try {
      // 1. Verificar conexión a internet
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        // Si no hay internet, verifica si ya se sincronizó antes
        final wasSyncedBefore = hasCompletedInitialSync();
        if (wasSyncedBefore) {
          return right(SyncResult(
            success: true,
            message: 'Usando datos en caché (sin conexión)',
            entitiesSynced: 0,
            reviewsSynced: 0,
          ));
        }
        return left(
            'Sin conexión a internet. No se puede realizar la sincronización inicial.');
      }

      int entitiesCount = 0;
      int reviewsCount = 0;

      // 2. Sincronizar entidades
      final entitiesResult = await syncEntitiesUsecase.call();
      entitiesResult.fold(
        (error) => throw Exception('Error al sincronizar entidades: $error'),
        (_) => entitiesCount++,
      );

      // 3. Sincronizar reviews
      final reviewsResult = await syncReviewsUsecase.call();
      reviewsResult.fold(
        (error) => throw Exception('Error al sincronizar reviews: $error'),
        (_) => reviewsCount++,
      );

      // 4. Marcar como sincronizado
      await prefs.setBool(_keySyncCompleted, true);
      await prefs.setString(_keyLastSyncDate, DateTime.now().toIso8601String());

      return right(SyncResult(
        success: true,
        message: 'Sincronización completada exitosamente',
        entitiesSynced: entitiesCount,
        reviewsSynced: reviewsCount,
      ));
    } catch (e) {
      return left('Error en sincronización: ${e.toString()}');
    }
  }

  /// Verifica si ya se realizó la sincronización inicial
  bool hasCompletedInitialSync() {
    return prefs.getBool(_keySyncCompleted) ?? false;
  }

  /// Obtiene la fecha de la última sincronización
  DateTime? getLastSyncDate() {
    final dateString = prefs.getString(_keyLastSyncDate);
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  /// Fuerza una nueva sincronización (útil para refresh manual)
  ///
  /// Limpia el flag de sincronización y ejecuta syncAll() nuevamente
  Future<Either<String, SyncResult>> forceSync() async {
    await prefs.setBool(_keySyncCompleted, false);
    return await syncAll();
  }

  /// Limpia el estado de sincronización (útil para testing o logout)
  Future<void> clearSyncState() async {
    await prefs.remove(_keySyncCompleted);
    await prefs.remove(_keyLastSyncDate);
  }
}
