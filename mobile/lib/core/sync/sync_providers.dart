import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/core/sync/initial_sync_service.dart';
import 'package:migra_ayuda/core/sync/sync_result.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// SHARED PREFERENCES PROVIDER
// ============================================================================

/// Provider de SharedPreferences
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// ============================================================================
// INITIAL SYNC SERVICE PROVIDER
// ============================================================================

/// Provider del servicio de sincronización inicial
final initialSyncServiceProvider = Provider<InitialSyncService>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  final syncEntitiesUsecase = ref.watch(syncAllEntitiesUsecaseProvider);
  final syncReviewsUsecase = ref.watch(syncAllReviewsUsecaseProvider);

  // Espera a que SharedPreferences esté disponible
  final prefsAsync = ref.watch(sharedPreferencesProvider);

  return prefsAsync.when(
    data: (prefs) => InitialSyncService(
      networkInfo: networkInfo,
      syncEntitiesUsecase: syncEntitiesUsecase,
      syncReviewsUsecase: syncReviewsUsecase,
      prefs: prefs,
    ),
    loading: () => throw Exception('SharedPreferences no disponible'),
    error: (error, stack) =>
        throw Exception('Error al cargar SharedPreferences: $error'),
  );
});

// ============================================================================
// INITIAL SYNC EXECUTION PROVIDER
// ============================================================================

/// Provider para ejecutar la sincronización inicial
///
/// Este provider se ejecuta automáticamente cuando se observa.
/// Descarga TODAS las entidades y reviews de Firebase y las guarda en Sembast.
final initialSyncProvider = FutureProvider<SyncResult>((ref) async {
  final syncService = ref.watch(initialSyncServiceProvider);

  final result = await syncService.syncAll();

  return result.fold(
    (error) => throw Exception(error),
    (syncResult) => syncResult,
  );
});

// ============================================================================
// SYNC STATUS PROVIDERS
// ============================================================================

/// Provider para verificar si ya se completó la sincronización inicial
final hasSyncedProvider = Provider<bool>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);

  return prefsAsync.when(
    data: (prefs) => prefs.getBool('initial_sync_completed') ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider para obtener la fecha de la última sincronización
final lastSyncDateProvider = Provider<DateTime?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);

  return prefsAsync.when(
    data: (prefs) {
      final dateString = prefs.getString('last_sync_date');
      if (dateString == null) return null;
      return DateTime.tryParse(dateString);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
