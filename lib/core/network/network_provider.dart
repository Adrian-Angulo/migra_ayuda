import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_info.dart';



/// Provider que proporciona la implementación de NetworkInfo
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

/// Provider que verifica el estado actual de la conexión
/// Este es un FutureProvider que se puede usar para verificaciones puntuales
/* final isConnectedProvider = FutureProvider<bool>((ref) async {
  final networkInfo = ref.watch(networkInfoProvider);
  return await networkInfo.isConnected;
}); */

/// StreamProvider que escucha los cambios de conectividad en tiempo real
/// Útil para mostrar banners o actualizar UI cuando cambia la conexión
/* final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
}); */
