import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapState {
  final bool isMapReady;
  final bool isTracking;
  final CameraState? cameraState; // Para saber dónde está apuntando el mapa

  MapState({
    this.isMapReady = false,
    this.isTracking = true,
    this.cameraState,
  });

  MapState copyWith({
    bool? isMapReady,
    bool? isTracking,
    CameraState? cameraState,
  }) =>
      MapState(
        isMapReady: isMapReady ?? this.isMapReady,
        isTracking: isTracking ?? this.isTracking,
        cameraState: cameraState ?? this.cameraState,
      );
}
