import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/sync/sync_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';

/// Provider que inicializa la sincronización automática de entidades.
/// Registra un callback en el SyncService para sincronizar cuando hay conexión.
final entitySyncInitializerProvider = Provider<void>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final repository = ref.watch(entityRepositoryProvider);

  syncService.registerSyncCallback(() async {
    final result = await repository.getAllEntities();
    result.fold(
      (error) => print('❌ Error al sincronizar entidades: $error'),
      (entities) =>
          print('✅ Entidades sincronizadas: ${entities.length} registros'),
    );
  });
});
