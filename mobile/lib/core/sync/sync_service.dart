import 'dart:async';
import 'package:migra_ayuda/core/network/network_info.dart';

/// Excepción personalizada para errores de sincronización
class SyncException implements Exception {
  final String message;
  SyncException(this.message);

  @override
  String toString() => 'SyncException: $message';
}

/// Servicio de sincronización que escucha cambios de conectividad
/// y ejecuta callbacks cuando se detecta conexión a internet
class SyncService {
  final NetworkInfo networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isConnected = false;

  // Lista de callbacks a ejecutar cuando hay conexión
  final List<Future<void> Function()> _syncCallbacks = [];

  // Flag para evitar múltiples sincronizaciones simultáneas
  bool _isSyncing = false;

  SyncService({required this.networkInfo});

  /// Inicializa el servicio de sincronización
  /// Escucha cambios de conectividad y ejecuta sincronización cuando se detecta conexión
  Future<void> initialize() async {
    // Verifica el estado inicial de conexión
    _isConnected = await networkInfo.isConnected;

    // Escucha cambios de conectividad
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen(
      (isConnected) async {
        final wasDisconnected = !_isConnected;
        _isConnected = isConnected;

        // Si cambió de desconectado a conectado, ejecuta sincronización
        if (wasDisconnected && isConnected) {
          await _executeSyncCallbacks();
        }
      },
      onError: (error) {
        print('Error en el stream de conectividad: $error');
      },
    );
  }

  /// Registra un callback para ejecutar cuando hay conexión
  /// El callback debe ser una función que retorne Future<void>
  void registerSyncCallback(Future<void> Function() callback) {
    _syncCallbacks.add(callback);
  }

  /// Elimina un callback registrado
  void unregisterSyncCallback(Future<void> Function() callback) {
    _syncCallbacks.remove(callback);
  }

  /// Ejecuta todos los callbacks de sincronización registrados
  Future<void> _executeSyncCallbacks() async {
    if (_isSyncing) {
      print('Sincronización ya en progreso, omitiendo...');
      return;
    }

    if (_syncCallbacks.isEmpty) {
      print('No hay callbacks de sincronización registrados');
      return;
    }

    _isSyncing = true;
    print('Iniciando sincronización automática...');

    try {
      // Ejecuta todos los callbacks en secuencia
      for (final callback in _syncCallbacks) {
        try {
          await callback();
        } catch (e) {
          print('Error al ejecutar callback de sincronización: $e');
          // Continúa con los siguientes callbacks aunque uno falle
        }
      }

      print('Sincronización completada exitosamente');
    } catch (e) {
      print('Error durante la sincronización: $e');
      throw SyncException('Error durante la sincronización: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Fuerza una sincronización manual (útil para pull-to-refresh)
  Future<void> forceSync() async {
    if (!_isConnected) {
      throw SyncException('No hay conexión a internet');
    }

    await _executeSyncCallbacks();
  }

  /// Verifica si hay una sincronización en progreso
  bool get isSyncing => _isSyncing;

  /// Verifica si hay conexión actualmente
  bool get isConnected => _isConnected;

  /// Limpia los recursos del servicio
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncCallbacks.clear();
  }
}
