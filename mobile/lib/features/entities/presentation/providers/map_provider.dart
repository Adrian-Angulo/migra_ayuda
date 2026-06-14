import 'package:flutter_riverpod/legacy.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/features/entities/domain/entities/map_state.dart';

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState());

  MapboxMap? _mapboxMap;
  Position? _lastKnownPosition;

  void setMapController(MapboxMap? controller) {
    if (controller == null) return;
    _mapboxMap = controller;
    // Ocultamos la barra de escala del mapa
    _mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Definimos los límites geográficos y de zoom permitidos en el mapa
    _mapboxMap!.setBounds(CameraBoundsOptions(
      bounds: CoordinateBounds(
          // Esquina suroeste del área permitida
          southwest: Point(coordinates: Position(-77.3400, 1.1400)),
          // Esquina noreste del área permitida
          northeast: Point(coordinates: Position(-77.2200, 1.2700)),
          infiniteBounds: false),
      minZoom: 12, // Zoom mínimo permitido
      maxZoom: 18, // Zoom máximo permitido
    ));

    _mapboxMap!.location.updateSettings(LocationComponentSettings(
        enabled: true, pulsingEnabled: true, puckBearingEnabled: true));

    state = state.copyWith(isMapReady: true);
  }

  /// Apaga el seguimiento cuando el usuario arrastra el mapa de forma manual
  void pauseTracking() {
    if (!state.isTracking) return; // Si ya estaba apagado, no hacemos nada
    state = state.copyWith(isTracking: false);
    print("Tracking pausado: El usuario está explorando el mapa.");
  }

  /// Enciende el seguimiento y vuela inmediatamente a la ubicación actual
  void resumeTracking() {
    state = state.copyWith(isTracking: true);
    if (_lastKnownPosition != null) {
      _moveCamera(_lastKnownPosition!);
    }
  }

  void location(Position gpsPosition) {
    if (!state.isMapReady || _mapboxMap == null || !state.isTracking) return;

    _moveCamera(gpsPosition);
  }

  // Método privado para evitar duplicar código de animación de cámara
  void _moveCamera(Position gpsPosition) {
    final targetPoint = Point(coordinates: gpsPosition);

    _mapboxMap!.easeTo(
      CameraOptions(center: targetPoint, zoom: 12.5),
      MapAnimationOptions(duration: 1500),
    );
  }
}

// El Provider global para que la UI escuche y use este controlador
final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
