import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/map/data/repository/map_repository_impl.dart';
import 'package:migra_ayuda/features/map/domain/entities/map_state.dart';
import 'package:migra_ayuda/features/map/domain/entities/route_result.dart';
import 'package:migra_ayuda/features/map/domain/usecases/calculate_route_usecase.dart';
import 'package:migra_ayuda/features/map/presentation/helpers/marker_icon_generator.dart';
import 'package:migra_ayuda/features/map/presentation/providers/map_providers.dart';

class MapNotifier extends StateNotifier<MapState> {
  final CalculateRouteUseCase _calculateRouteUseCase;

  MapNotifier({CalculateRouteUseCase? calculateRouteUseCase})
      : _calculateRouteUseCase =
            calculateRouteUseCase ?? CalculateRouteUseCase(MapRepositoryImpl()),
        super(MapState());

  MapboxMap? _mapboxMap;
  Position? _lastKnownPosition;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;

  List<EntityEntity> _currentEntities = [];

  List<Position> _activeRoutePoints = [];
  int _activeRouteColor = 0xFF1565C0;
  double _activeRouteWidth = 5.0;
  bool _isUpdatingRouteProgress = false;

  void selectEntity(EntityEntity entity) {
    state = state.copyWith(selectEntity: entity);
    if (_currentEntities.isNotEmpty) {
      addMarkers(_currentEntities);
    }
  }

  Future<void> setMapController(MapboxMap? controller) async {
    if (controller == null) return;
    _mapboxMap = controller;
    _pointAnnotationManager = null;
    _mapboxMap!.gestures.updateSettings(GesturesSettings(pitchEnabled: false));
    _mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    _mapboxMap!.setBounds(CameraBoundsOptions(
      bounds: CoordinateBounds(
          southwest: Point(coordinates: Position(-77.3400, 1.1400)),
          northeast: Point(coordinates: Position(-77.2200, 1.2700)),
          infiniteBounds: false),
      minZoom: 12,
      maxZoom: 18,
      minPitch: 0.0,
      maxPitch: 0.0,
    ));

    _mapboxMap!.location.updateSettings(LocationComponentSettings(
        enabled: true, pulsingEnabled: true, puckBearingEnabled: true));

    _polylineAnnotationManager =
        await _mapboxMap!.annotations.createPolylineAnnotationManager();

    state = state.copyWith(isMapReady: true, hasMarkers: false);

    if (_currentEntities.isNotEmpty) {
      await addMarkers(_currentEntities);
    }
  }

  void pauseTracking() {
    if (!state.isTracking) return;
    state = state.copyWith(isTracking: false);
  }

  void resumeTracking() {
    state = state.copyWith(isTracking: true);
    if (_lastKnownPosition != null) {
      _moveCamera(_lastKnownPosition!);
    }
  }

  void location(Position gpsPosition) {
    _lastKnownPosition = gpsPosition;
    if (!state.isMapReady || _mapboxMap == null) return;
    if (state.isTracking) {
      _moveCamera(gpsPosition);
    }
    if (state.hasActiveRoute && _activeRoutePoints.isNotEmpty) {
      _updateRouteProgress(gpsPosition);
    }
  }

  double _calculateDistanceMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // metros
    final double dLat = (lat2 - lat1) * (math.pi / 180.0);
    final double dLon = (lon2 - lon1) * (math.pi / 180.0);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _updateRouteProgress(Position gpsPosition) async {
    if (_isUpdatingRouteProgress ||
        _activeRoutePoints.isEmpty ||
        _polylineAnnotationManager == null) {
      return;
    }

    _isUpdatingRouteProgress = true;
    try {
      final destPoint = _activeRoutePoints.last;
      final distanceToDest = _calculateDistanceMeters(
        gpsPosition.lat.toDouble(),
        gpsPosition.lng.toDouble(),
        destPoint.lat.toDouble(),
        destPoint.lng.toDouble(),
      );

      
      if (distanceToDest <= 15.0) {
       
        await clearRoute();
        return;
      }

     
      int closestIndex = 0;
      double minDistance = double.infinity;

      for (int i = 0; i < _activeRoutePoints.length; i++) {
        final point = _activeRoutePoints[i];
        final dist = _calculateDistanceMeters(
          gpsPosition.lat.toDouble(),
          gpsPosition.lng.toDouble(),
          point.lat.toDouble(),
          point.lng.toDouble(),
        );
        if (dist < minDistance) {
          minDistance = dist;
          closestIndex = i;
        }
      }

      // Si el usuario avanza y el vértice más cercano es posterior (o está dentro de 40m de la ruta)
      if (minDistance <= 40.0 && closestIndex > 0) {
        final remaining = _activeRoutePoints.sublist(closestIndex);
        _activeRoutePoints = [gpsPosition, ...remaining];

        await _polylineAnnotationManager!.deleteAll();
        final polylineOptions = PolylineAnnotationOptions(
          geometry: LineString(coordinates: _activeRoutePoints),
          lineColor: _activeRouteColor,
          lineWidth: _activeRouteWidth,
          lineJoin: LineJoin.ROUND,
        );
        await _polylineAnnotationManager!.create(polylineOptions);
      }
    } catch (e) {
      debugPrint("⚠️ Error al actualizar progreso de ruta: $e");
    } finally {
      _isUpdatingRouteProgress = false;
    }
  }

  void clearSelectEntity() {
    state = state.copyWith(clearSelectEntity: true);
    if (_currentEntities.isNotEmpty) {
      addMarkers(_currentEntities);
    }
    debugPrint("✅ Entidad deseleccionada");
  }

  Future<void> addMarkers(List<EntityEntity> entities) async {
    _currentEntities = entities;
    if (_mapboxMap == null) {
      return;
    }

    try {
      if (_pointAnnotationManager == null) {
        _pointAnnotationManager =
            await _mapboxMap!.annotations.createPointAnnotationManager();

        _pointAnnotationManager?.tapEvents(
          onTap: (PointAnnotation anotation) {
            try {
              final getEntity = _currentEntities.firstWhere(
                (entity) => entity.name.trim() == anotation.textField?.trim(),
              );
              selectEntity(getEntity);
            } catch (e) {
              debugPrint(
                  "⚠️ No se encontró la entidad para el marcador: ${anotation.textField}");
            }
          },
        );
      }

      await _pointAnnotationManager!.deleteAll();
      await _createAnnotations(entities);
    } catch (e) {
      _pointAnnotationManager = null;
    }
  }

  Future<void> _createAnnotations(List<EntityEntity> entities) async {
    if (_pointAnnotationManager == null || entities.isEmpty) {
      state = state.copyWith(hasMarkers: entities.isNotEmpty);
      return;
    }

    final defaultIconBytes =
        await MarkerIconGenerator.getMarkerBytes(isSelected: false);
    final selectedIconBytes =
        await MarkerIconGenerator.getMarkerBytes(isSelected: true);

    final annotations = entities.map((entity) {
      final isSelected = state.selectEntity?.id == entity.id ||
          state.selectEntity?.name == entity.name;

      return PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            entity.localitation.longitude,
            entity.localitation.latitude,
          ),
        ),
        image: isSelected ? selectedIconBytes : defaultIconBytes,
        iconSize: isSelected ? 1.60 : 1.35,
        iconAnchor: IconAnchor.BOTTOM,
        textField: entity.name,
        textOffset: [0.0, 0.6],
        textSize: 13.0,
        textAnchor: TextAnchor.TOP,
        textColor: 0xFF212121,
        textHaloColor: 0xFFFFFFFF,
        textHaloWidth: 1.8,
      );
    }).toList();

    await _pointAnnotationManager?.createMulti(annotations);
    state = state.copyWith(hasMarkers: true);
  }

  void _moveCamera(Position gpsPosition) {
    final targetPoint = Point(coordinates: gpsPosition);

    _mapboxMap!.easeTo(
      CameraOptions(center: targetPoint, zoom: 16, pitch: 0),
      MapAnimationOptions(duration: 1500),
    );
  }

  Future<void> drawRouteToEntity(EntityEntity entity) async {
    if (_mapboxMap == null ||
        _polylineAnnotationManager == null ||
        _lastKnownPosition == null) {
      return;
    }

    state = state.copyWith(isDrawingRoute: true);

    try {
      final routeResult = await _calculateRouteUseCase(
        originLng: _lastKnownPosition!.lng.toDouble(),
        originLat: _lastKnownPosition!.lat.toDouble(),
        destLng: entity.localitation.longitude,
        destLat: entity.localitation.latitude,
      );

      if (routeResult.points.isEmpty) {
        debugPrint("⚠️ No se encontró ruta disponible");
        state = state.copyWith(isDrawingRoute: false);
        return;
      }

      await _polylineAnnotationManager!.deleteAll();

      final int lineColor;
      final double lineWidth;

      switch (routeResult.sourceType) {
        case RouteSourceType.mapboxApi:
          lineColor = 0xFF1565C0; // Azul
          lineWidth = 5.0;
          break;
        case RouteSourceType.directFallback:
          lineColor = 0xFFFF6D00; // Naranja
          lineWidth = 4.5;
          break;
      }

      _activeRoutePoints = List.from(routeResult.points);
      _activeRouteColor = lineColor;
      _activeRouteWidth = lineWidth;

      final polylineOptions = PolylineAnnotationOptions(
        geometry: LineString(coordinates: routeResult.points),
        lineColor: lineColor,
        lineWidth: lineWidth,
        lineJoin: LineJoin.ROUND,
      );

      await _polylineAnnotationManager!.create(polylineOptions);

      state = state.copyWith(
        isOfflineRoute: routeResult.isOffline,
        isFallbackRoute: routeResult.isFallback,
        routeMessage: routeResult.message,
        isDrawingRoute: false,
        hasActiveRoute: true,
      );
    } catch (e) {
      state = state.copyWith(isDrawingRoute: false);
    }
  }

  Future<void> clearRoute() async {
    _activeRoutePoints = [];
    if (_polylineAnnotationManager != null) {
      await _polylineAnnotationManager!.deleteAll();
    }
    state = state.copyWith(clearRouteState: true);
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  final calculateRouteUseCase = ref.watch(calculateRouteUseCaseProvider);
  return MapNotifier(calculateRouteUseCase: calculateRouteUseCase);
});
