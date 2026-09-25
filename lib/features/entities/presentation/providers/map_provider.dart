import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/localitation/map_services.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/entities/map_state.dart';

class MarkerIconGenerator {
  static Uint8List? _cachedDefaultPin;
  static Uint8List? _cachedSelectedPin;

  static Future<Uint8List> getMarkerBytes({bool isSelected = false}) async {
    if (isSelected && _cachedSelectedPin != null) return _cachedSelectedPin!;
    if (!isSelected && _cachedDefaultPin != null) return _cachedDefaultPin!;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 96.0;

    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(48, 88), 9, shadowPaint);

    final paint = Paint()
      ..color = isSelected ? const Color(0xFFE53935) : const Color(0xFF00897B)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(48, 86);
    path.cubicTo(
      48 - 28,
      48 + 8,
      48 - 30,
      48 - 22,
      48,
      48 - 32,
    );
    path.cubicTo(
      48 + 30,
      48 - 32,
      48 + 28,
      48 + 8,
      48,
      86,
    );
    path.close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawPath(path, borderPaint);

    final centerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(48, 38), 9, centerCirclePaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    if (isSelected) {
      _cachedSelectedPin = bytes;
    } else {
      _cachedDefaultPin = bytes;
    }

    return bytes;
  }
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState());

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

      // Si ha llegado a menos de 15 metros del destino, finalizar la ruta
      if (distanceToDest <= 15.0) {
        debugPrint(
            "🏁 Has llegado a tu destino (${distanceToDest.toStringAsFixed(1)}m)");
        await clearRoute();
        return;
      }

      // Buscar el vértice más cercano en la polilínea actual
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
        iconSize: isSelected ? 1.35 : 1.15,
        iconAnchor: IconAnchor.BOTTOM,
        textField: entity.name,
        textOffset: [0.0, -0.6],
        textSize: 13.0,
        textAnchor: TextAnchor.TOP,
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
      final routeResult = await MapServices.fetchRoute(
        originLng: _lastKnownPosition!.lng.toDouble(),
        originLat: _lastKnownPosition!.lat.toDouble(),
        destLng: entity.localitation.longitude,
        destLat: entity.localitation.latitude,
        entityId: entity.id,
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
  return MapNotifier();
});
