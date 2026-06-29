import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/network/network_provider.dart';
import 'package:migra_ayuda/core/sync/sync_service.dart';

/// Provider que proporciona la instancia de SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  final syncService = SyncService(networkInfo: networkInfo);

  // Limpia el servicio cuando el provider se destruye
  ref.onDispose(() {
    syncService.dispose();
  });

  return syncService;
});

/// Provider que expone el estado de conexión actual
/// Útil para mostrar banners de "Sin conexión" en la UI
final connectionStatusProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});
