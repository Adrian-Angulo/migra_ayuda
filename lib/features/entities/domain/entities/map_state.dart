import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

class MapState {
  final bool isMapReady;
  final bool isTracking;
  final CameraState? cameraState; // Para saber dónde está apuntando el mapa
  final bool hasMarkers; // Para saber si ya se agregaron los marcadores
  final EntityEntity? selectEntity;
  final bool isOfflineRoute;
  final bool isFallbackRoute;
  final String? routeMessage;
  final bool isDrawingRoute;
  final bool hasActiveRoute;

  MapState({
    this.isMapReady = false,
    this.isTracking = true,
    this.cameraState,
    this.hasMarkers = false,
    this.selectEntity,
    this.isOfflineRoute = false,
    this.isFallbackRoute = false,
    this.routeMessage,
    this.isDrawingRoute = false,
    this.hasActiveRoute = false,
  });

  MapState copyWith({
    bool? isMapReady,
    bool? isTracking,
    CameraState? cameraState,
    bool? hasMarkers,
    EntityEntity? selectEntity,
    bool clearSelectEntity = false, // 🆕 Flag para limpiar la entidad
    bool? isOfflineRoute,
    bool? isFallbackRoute,
    String? routeMessage,
    bool? isDrawingRoute,
    bool? hasActiveRoute,
    bool clearRouteState = false,
  }) =>
      MapState(
        isMapReady: isMapReady ?? this.isMapReady,
        isTracking: isTracking ?? this.isTracking,
        cameraState: cameraState ?? this.cameraState,
        hasMarkers: hasMarkers ?? this.hasMarkers,
        selectEntity: clearSelectEntity
            ? null
            : (selectEntity ?? this.selectEntity),
        isOfflineRoute: clearRouteState ? false : (isOfflineRoute ?? this.isOfflineRoute),
        isFallbackRoute: clearRouteState ? false : (isFallbackRoute ?? this.isFallbackRoute),
        routeMessage: clearRouteState ? null : (routeMessage ?? this.routeMessage),
        isDrawingRoute: clearRouteState ? false : (isDrawingRoute ?? this.isDrawingRoute),
        hasActiveRoute: clearRouteState ? false : (hasActiveRoute ?? this.hasActiveRoute),
      );
}

