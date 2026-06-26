import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

class MapState {
  final bool isMapReady;
  final bool isTracking;
  final CameraState? cameraState; // Para saber dónde está apuntando el mapa
  final bool hasMarkers; // Para saber si ya se agregaron los marcadores
  final EntityEntity? selectEntity;

  MapState({
    this.isMapReady = false,
    this.isTracking = true,
    this.cameraState,
    this.hasMarkers = false,
    this.selectEntity,
  });

  MapState copyWith({
    bool? isMapReady,
    bool? isTracking,
    CameraState? cameraState,
    bool? hasMarkers,
    EntityEntity? selectEntity,
  }) =>
      MapState(
        isMapReady: isMapReady ?? this.isMapReady,
        isTracking: isTracking ?? this.isTracking,
        cameraState: cameraState ?? this.cameraState,
        hasMarkers: hasMarkers ?? this.hasMarkers,
        selectEntity: selectEntity,
      );
}
