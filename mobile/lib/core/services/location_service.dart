import 'package:geolocator/geolocator.dart';

/// Servicio para manejar la ubicación del dispositivo
abstract class LocationService {
  /// Stream que emite la ubicación en tiempo real
  Stream<Position> get locationStream;

  /// Obtiene la ubicación actual una sola vez
  Future<Position?> getCurrentLocation();

  /// Verifica si los permisos están otorgados
  Future<bool> hasPermission();

  /// Solicita permisos de ubicación
  Future<bool> requestPermission();

  /// Verifica si el GPS está habilitado
  Future<bool> isLocationServiceEnabled();
}
