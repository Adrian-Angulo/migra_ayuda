import 'package:connectivity_plus/connectivity_plus.dart';

/// Interfaz abstracta para verificar el estado de la conexión de red
abstract class NetworkInfo {
  /// Verifica si hay conexión a internet
  /// Retorna true si hay conexión WiFi o móvil, false en caso contrario
  Future<bool> get isConnected;

  /// Stream que emite eventos cuando cambia el estado de la conexión
  Stream<bool> get onConnectivityChanged;
}

/// Implementación de NetworkInfo usando connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    try {
      final result = await connectivity.checkConnectivity();
      return _isConnectedResult(result);
    } catch (e) {
      // En caso de error, asumimos que no hay conexión
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((result) {
      return _isConnectedResult(result);
    });
  }

  /// Verifica si el resultado de conectividad indica una conexión activa
  bool _isConnectedResult(List<ConnectivityResult> result) {
    // Verifica si hay conexión WiFi o móvil
    return result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.ethernet);
  }
}
