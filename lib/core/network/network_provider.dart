import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_info.dart';

/// Provider que proporciona la instancia de Connectivity
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Provider que proporciona la implementación de NetworkInfo
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfoImpl(connectivity);
});

/// Provider que verifica el estado actual de la conexión
/// Este es un FutureProvider que se puede usar para verificaciones puntuales
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final networkInfo = ref.watch(networkInfoProvider);
  return await networkInfo.isConnected;
});

/// StreamProvider que escucha los cambios de conectividad en tiempo real
/// Útil para mostrar banners o actualizar UI cuando cambia la conexión
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});
