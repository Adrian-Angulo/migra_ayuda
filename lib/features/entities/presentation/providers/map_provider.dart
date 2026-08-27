import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/localitation/map_services.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/entities/map_state.dart';

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState());

  MapboxMap? _mapboxMap;
  Position? _lastKnownPosition;
  PointAnnotationManager?
      _pointAnnotationManager; // 👈 Nuevo: gestor de marcadores

  PolylineAnnotationManager? _polylineAnnotationManager; // para dibujar rutas

  void selectEntity(EntityEntity entity) {
    state = state.copyWith(selectEntity: entity);
  }

  Future<void> setMapController(MapboxMap? controller) async {
    if (controller == null) return;
    _mapboxMap = controller;

    // 🔄 Reseteamos el gestor de anotaciones cuando se crea un nuevo mapa
    _pointAnnotationManager = null;

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

    _polylineAnnotationManager =
        await _mapboxMap!.annotations.createPolylineAnnotationManager();

    state = state.copyWith(isMapReady: true, hasMarkers: false);
  }

  /// Apaga el seguimiento cuando el usuario arrastra el mapa de forma manual
  void pauseTracking() {
    if (!state.isTracking) return; // Si ya estaba apagado, no hacemos nada
    state = state.copyWith(isTracking: false);
    debugPrint("Tracking pausado: El usuario está explorando el mapa.");
  }

  /// Enciende el seguimiento y vuela inmediatamente a la ubicación actual
  void resumeTracking() {
    state = state.copyWith(isTracking: true);
    if (_lastKnownPosition != null) {
      _moveCamera(_lastKnownPosition!);
      debugPrint("Traking renudado");
    }
  }

  void location(Position gpsPosition) {
    // Siempre guardamos la última posición conocida, incluso si el tracking está pausado
    _lastKnownPosition = gpsPosition;

    // Solo movemos la cámara si el mapa está listo y el tracking está activo
    if (!state.isMapReady || _mapboxMap == null || !state.isTracking) return;

    _moveCamera(gpsPosition);
  }

  /// 🆕 Limpiar la entidad seleccionada (resetear a null)
  void clearSelectEntity() {
    state = state.copyWith(clearSelectEntity: true);
    debugPrint("✅ Entidad deseleccionada");
  }

  /// 📍 Agrega marcadores al mapa desde una lista de ubicaciones
  Future<void> addMarkers(List<EntityEntity> entities) async {
    if (_mapboxMap == null) {
      debugPrint("⚠️ El mapa aún no está listo");
      return;
    }

    // Si ya existe el gestor de anotaciones, intentamos limpiarlo
    if (_pointAnnotationManager != null) {
      try {
        await _pointAnnotationManager!.deleteAll();
        _createAnnotations(entities);
      } catch (e) {
        // Si falla (porque el mapa se reinició), creamos un nuevo gestor
        debugPrint("⚠️ El gestor anterior no es válido, creando uno nuevo...");
        _pointAnnotationManager = null;
        await addMarkers(entities); // Llamada recursiva para crear nuevo gestor
      }
      return;
    }

    // Creamos el gestor de anotaciones por primera vez
    _mapboxMap!.annotations.createPointAnnotationManager().then((manager) {
      _pointAnnotationManager = manager;

      _pointAnnotationManager?.tapEvents(
        onTap: (PointAnnotation anotation) {
          // Buscar la entidad que coincida con el texto del marcador
          try {
            final getEntity = entities.firstWhere(
              (entity) => entity.name == anotation.textField,
            );
            state = state.copyWith(selectEntity: getEntity);
          } catch (e) {
            debugPrint(
                "⚠️ No se encontró la entidad para el marcador: ${anotation.textField}");
          }
        },
      );
      _createAnnotations(entities);
    });
  }

  /// Método privado que crea las anotaciones
  void _createAnnotations(List<EntityEntity> entities) async {
    final annotations = entities.map((entity) {
      return PointAnnotationOptions(

          // 📌 Coordenadas del marcador
          geometry: Point(
            coordinates: Position(
              entity.localitation.longitude,
              entity.localitation.latitude,
            ),
          ),
          // 🎨 Icono del marcador (puedes cambiarlo)
          iconImage: state.selectEntity == entity
              ? "pin"
              : "mapbox_custom_marker", // Icono predeterminado de Mapbox
          iconSize: 0.1,
          iconAnchor: IconAnchor.BOTTOM,
          // 📝 Texto opcional (aparece al hacer clic)
          textField: entity.name,
          textOffset: [0.0, -0.5],
          textSize: 12.0,
          textAnchor: TextAnchor.TOP);
    }).toList();

    // Agregamos todos los marcadores al mapa
    _pointAnnotationManager?.createMulti(annotations);

    state = state.copyWith(hasMarkers: true);
  }

  // Método privado para evitar duplicar código de animación de cámara
  void _moveCamera(Position gpsPosition) {
    final targetPoint = Point(coordinates: gpsPosition);

    _mapboxMap!.easeTo(
      CameraOptions(center: targetPoint),
      MapAnimationOptions(duration: 1500),
    );
  }

  /// 🗺️ Dibujar ruta desde ubicación actual hasta una entidad con soporte offline
  Future<void> drawRouteToEntity(EntityEntity entity) async {
    if (_mapboxMap == null ||
        _polylineAnnotationManager == null ||
        _lastKnownPosition == null) {
      debugPrint("⚠️ Mapa o ubicación no disponible para trazar ruta");
      return;
    }

    state = state.copyWith(isDrawingRoute: true);

    try {
      // Obtener puntos de la ruta usando el servicio híbrido (API -> Caché -> Fallback Directo)
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

      // Limpiar rutas anteriores
      await _polylineAnnotationManager!.deleteAll();

      // Definir color y grosor según el tipo de ruta
      final int lineColor;
      final double lineWidth;

      switch (routeResult.sourceType) {
        case RouteSourceType.online:
          lineColor = 0xFF1E88E5; // Azul estándar online
          lineWidth = 5.0;
          break;
        case RouteSourceType.cached:
          lineColor = 0xFF00897B; // Verde azulado / Teal para caché
          lineWidth = 5.0;
          break;
        case RouteSourceType.directFallback:
          lineColor = 0xFFFF6D00; // Naranja intenso para rumbo directo
          lineWidth = 4.5;
          break;
      }

      // Crear la polilínea en Mapbox
      final polylineOptions = PolylineAnnotationOptions(
        geometry: LineString(coordinates: routeResult.points),
        lineColor: lineColor,
        lineWidth: lineWidth,
        lineJoin: LineJoin.ROUND,
      );

      // Dibujar en el mapa
      await _polylineAnnotationManager!.create(polylineOptions);

      state = state.copyWith(
        isOfflineRoute: routeResult.isOffline,
        isFallbackRoute: routeResult.isFallback,
        routeMessage: routeResult.message,
        isDrawingRoute: false,
        hasActiveRoute: true,
      );

      debugPrint(
          "✅ Ruta trazada (${routeResult.sourceType.name}) con ${routeResult.points.length} puntos: ${routeResult.message}");
    } catch (e) {
      debugPrint("❌ Error al trazar ruta: $e");
      state = state.copyWith(isDrawingRoute: false);
    }
  }

  /// 🧹 Limpiar ruta del mapa
  Future<void> clearRoute() async {
    if (_polylineAnnotationManager != null) {
      await _polylineAnnotationManager!.deleteAll();
    }
    state = state.copyWith(clearRouteState: true);
  }
}

// El Provider global para que la UI escuche y use este controlador
final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
