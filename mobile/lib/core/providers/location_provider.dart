import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:migra_ayuda/core/services/location_service.dart';
import 'package:migra_ayuda/core/services/location_service_impl.dart';

/// Provider del servicio de ubicación
final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationServiceImpl();
  ref.onDispose(() => service.dispose());
  return service;
});

/// StreamProvider que emite la ubicación en tiempo real
final userLocationStreamProvider = StreamProvider<Position?>((ref) async* {
  final locationService = ref.watch(locationServiceProvider);

  // Verifica permisos y GPS
  final serviceEnabled = await locationService.isLocationServiceEnabled();
  if (!serviceEnabled) {
    yield null;
    return;
  }

  final hasPermission = await locationService.hasPermission();
  if (!hasPermission) {
    final granted = await locationService.requestPermission();
    if (!granted) {
      yield null;
      return;
    }
  }

  // Obtiene ubicación inicial
  final initialPosition = await locationService.getCurrentLocation();
  if (initialPosition != null) {
    yield initialPosition;
  }

  // Escucha cambios en tiempo real
  await for (final position in locationService.locationStream) {
    yield position;
  }
});

/// Notifier para controlar si se debe centrar el mapa en la ubicación del usuario
class CenterOnUserLocationNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void trigger() => state = true;
  void reset() => state = false;
}

final centerOnUserLocationProvider =
    NotifierProvider<CenterOnUserLocationNotifier, bool>(
  CenterOnUserLocationNotifier.new,
);

/// Notifier para trackear si ya se solicitaron permisos de ubicación
/// Esto evita solicitar permisos múltiples veces
class LocationPermissionRequestedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markAsRequested() => state = true;
}

final locationPermissionRequestedProvider =
    NotifierProvider<LocationPermissionRequestedNotifier, bool>(
  LocationPermissionRequestedNotifier.new,
);
