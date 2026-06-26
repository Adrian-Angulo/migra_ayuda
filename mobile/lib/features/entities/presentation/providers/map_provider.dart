import 'package:flutter_riverpod/legacy.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/constants/list_fake.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/entities/map_state.dart';

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState());

  MapboxMap? _mapboxMap;
  Position? _lastKnownPosition;
  PointAnnotationManager?
      _pointAnnotationManager; // 👈 Nuevo: gestor de marcadores

  void setMapController(MapboxMap? controller) {
    
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

    /* // 📍 Lista de ejemplo con 3 ubicaciones
    
    addMarkers(listaEntityFake); */

    state = state.copyWith(isMapReady: true, hasMarkers: false);
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
      print("Traking renudado");
    }
  }

  void location(Position gpsPosition) {
    // Siempre guardamos la última posición conocida, incluso si el tracking está pausado
    _lastKnownPosition = gpsPosition;

    // Solo movemos la cámara si el mapa está listo y el tracking está activo
    if (!state.isMapReady || _mapboxMap == null || !state.isTracking) return;

    _moveCamera(gpsPosition);
  }

  /// 📍 Agrega marcadores al mapa desde una lista de ubicaciones
  Future<void> addMarkers(List<EntityEntity> entities) async {
    if (_mapboxMap == null) {
      print("⚠️ El mapa aún no está listo");
      return;
    }

    // Si ya existe el gestor de anotaciones, intentamos limpiarlo
    if (_pointAnnotationManager != null) {
      try {
        await _pointAnnotationManager!.deleteAll();
        _createAnnotations(entities);
      } catch (e) {
        // Si falla (porque el mapa se reinició), creamos un nuevo gestor
        print("⚠️ El gestor anterior no es válido, creando uno nuevo...");
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
          final getEntity = entities.firstWhere(
            (entity) => entity.name == anotation.textField,
            orElse: () => entities.first,
          );
          state = state.copyWith(selectEntity: getEntity);
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
          iconImage: state.selectEntity == entity ? "pin" : "mapbox_custom_marker"  , // Icono predeterminado de Mapbox
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
      CameraOptions(center: targetPoint, zoom: 12.5),
      MapAnimationOptions(duration: 1500),
    );
  }
}

// El Provider global para que la UI escuche y use este controlador
final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
