import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:migra_ayuda/core/services/location_service.dart';

/// Implementación del servicio de ubicación usando Geolocator
class LocationServiceImpl implements LocationService {
  StreamController<Position>? _locationController;
  StreamSubscription<Position>? _positionSubscription;

  @override
  Stream<Position> get locationStream {
    _locationController ??= StreamController<Position>.broadcast(
      onListen: _startLocationUpdates,
      onCancel: _stopLocationUpdates,
    );
    return _locationController!.stream;
  }

  void _startLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualiza cada 10 metros
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _locationController?.add(position);
      },
      onError: (error) {
        _locationController?.addError(error);
      },
    );
  }

  void _stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  Future<Position?> getCurrentLocation() async {
    try {
      // Verifica si el servicio está habilitado
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // Verifica permisos
      final hasPermissions = await hasPermission();
      if (!hasPermissions) {
        final granted = await requestPermission();
        if (!granted) return null;
      }

      // Obtiene la ubicación
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Limpia los recursos
  void dispose() {
    _stopLocationUpdates();
    _locationController?.close();
    _locationController = null;
  }
}
