import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/sync/sync_provider.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';

/// Provider que inicializa la sincronización automática de reviews
/// Registra un callback en el SyncService para sincronizar cuando hay conexión
final reviewSyncInitializerProvider = Provider<void>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final reviewRepository = ref.watch(reviewRepositoryProvider);

  // Registra el callback de sincronización
  syncService.registerSyncCallback(() async {
    print('🔄 Sincronizando reviews...');

    // Sincroniza las reviews pendientes
    final result = await reviewRepository.syncPendingReviews();

    result.fold(
      (error) => print('❌ Error al sincronizar reviews: $error'),
      (_) => print('✅ Reviews sincronizadas correctamente'),
    );
  });

  // Limpia el callback cuando el provider se destruye
  ref.onDispose(() {
    // No es necesario hacer nada aquí, el SyncService se limpia automáticamente
  });
});
