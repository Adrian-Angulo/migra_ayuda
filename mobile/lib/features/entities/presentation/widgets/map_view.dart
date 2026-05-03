import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/providers/location_provider.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

class MapView extends ConsumerStatefulWidget {
  final List<EntityEntity> entities;
  final EntityEntity? selectedEntity;
  final Function(EntityEntity)? onMarkerTap;

  const MapView({
    super.key,
    this.entities = const [],
    this.selectedEntity,
    this.onMarkerTap,
  });

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  final MapController _mapController = MapController();
  Position? _lastUserPosition;

  @override
  void initState() {
    super.initState();
    // Solicita permisos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  Future<void> _requestLocationPermission() async {
    final locationService = ref.read(locationServiceProvider);
    final hasPermission = await locationService.hasPermission();

    if (!hasPermission) {
      await locationService.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLocationAsync = ref.watch(userLocationStreamProvider);

    // Escucha cambios en el flag de centrado
    ref.listen<bool>(centerOnUserLocationProvider, (previous, next) {
      if (next && _lastUserPosition != null) {
        // Centra el mapa en la ubicación del usuario
        _mapController.move(
          LatLng(_lastUserPosition!.latitude, _lastUserPosition!.longitude),
          16.0,
        );
        // Resetea el flag
        Future.microtask(() {
          ref.read(centerOnUserLocationProvider.notifier).reset();
        });
      }
    });

    // Escucha cambios en la ubicación del usuario
    ref.listen<AsyncValue<Position?>>(userLocationStreamProvider,
        (previous, next) {
      next.whenData((position) {
        if (position != null) {
          _lastUserPosition = position;
        }
      });
    });

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _getInitialCenter(),
        initialZoom: 14.5,
        minZoom: 12,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=sCCRiCEG8SLjrAKmpanU',
        ),
        // Marcadores de entidades
        if (widget.entities.isNotEmpty)
          MarkerLayer(
            markers: _buildEntityMarkers(context),
          ),
        // Marcador de ubicación del usuario
        userLocationAsync.when(
          data: (position) {
            if (position == null) return const SizedBox.shrink();
            return MarkerLayer(
              markers: [_buildUserLocationMarker(position)],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  LatLng _getInitialCenter() {
    // Prioridad 1: Ubicación del usuario (si está disponible)
    final userLocationAsync = ref.read(userLocationStreamProvider);
    final userPosition = userLocationAsync.value;

    if (userPosition != null) {
      _lastUserPosition = userPosition;
      return LatLng(
        userPosition.latitude,
        userPosition.longitude,
      );
    }

    // Prioridad 2: Si hay ubicación guardada del usuario
    if (_lastUserPosition != null) {
      return LatLng(
        _lastUserPosition!.latitude,
        _lastUserPosition!.longitude,
      );
    }

    // Prioridad 3: Centro de entidades (si hay)
    if (widget.entities.isNotEmpty) {
      double totalLat = 0;
      double totalLng = 0;

      for (final entity in widget.entities) {
        totalLat += entity.localitation.latitude;
        totalLng += entity.localitation.longitude;
      }

      return LatLng(
        totalLat / widget.entities.length,
        totalLng / widget.entities.length,
      );
    }

    // Prioridad 4: Ubicación por defecto
    return const LatLng(1.2136, -77.2811);
  }

  /// Construye el marcador de ubicación del usuario
  Marker _buildUserLocationMarker(Position position) {
    return Marker(
      point: LatLng(position.latitude, position.longitude),
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo exterior pulsante (efecto de radar)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.2),
            ),
          ),
          // Círculo medio
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.3),
            ),
          ),
          // Punto central (ubicación exacta)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildEntityMarkers(BuildContext context) {
    return widget.entities.map((entity) {
      final isSelected = widget.selectedEntity?.id == entity.id;

      return Marker(
        point: LatLng(
          entity.localitation.latitude,
          entity.localitation.longitude,
        ),
        width: isSelected ? 60 : 50,
        height: isSelected ? 60 : 50,
        child: GestureDetector(
          onTap: () => widget.onMarkerTap?.call(entity),
          child: _buildMarkerWidget(entity, isSelected),
        ),
      );
    }).toList();
  }

  Widget _buildMarkerWidget(EntityEntity entity, bool isSelected) {
    // Determina el color según el servicio principal
    final color = _getColorForService(
      entity.services.isNotEmpty ? entity.services.first : '',
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Sombra
        if (isSelected)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),

        // Marcador principal
        Container(
          width: isSelected ? 50 : 40,
          height: isSelected ? 50 : 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getIconForService(
              entity.services.isNotEmpty ? entity.services.first : '',
            ),
            color: Colors.white,
            size: isSelected ? 24 : 20,
          ),
        ),

        // Punto inferior del marcador
        Positioned(
          bottom: -8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForService(String service) {
    final serviceLower = service.toLowerCase();

    if (serviceLower.contains('aliment') || serviceLower.contains('comida')) {
      return const Color(0xFFFF6B6B); // Rojo para alimentación
    } else if (serviceLower.contains('salud') ||
        serviceLower.contains('medic')) {
      return const Color(0xFF4ECDC4); // Turquesa para salud
    } else if (serviceLower.contains('alojamiento') ||
        serviceLower.contains('vivienda')) {
      return const Color(0xFFFFBE0B); // Amarillo para alojamiento
    } else if (serviceLower.contains('trabajo') ||
        serviceLower.contains('empleo')) {
      return const Color(0xFF95E1D3); // Verde agua para trabajo
    } else if (serviceLower.contains('transporte')) {
      return const Color(0xFF9B59B6); // Morado para transporte
    } else {
      return const Color(0xFF5F9EA0); // Color por defecto (teal)
    }
  }

  IconData _getIconForService(String service) {
    final serviceLower = service.toLowerCase();

    if (serviceLower.contains('aliment') || serviceLower.contains('comida')) {
      return Icons.restaurant;
    } else if (serviceLower.contains('salud') ||
        serviceLower.contains('medic')) {
      return Icons.local_hospital;
    } else if (serviceLower.contains('alojamiento') ||
        serviceLower.contains('vivienda')) {
      return Icons.home;
    } else if (serviceLower.contains('trabajo') ||
        serviceLower.contains('empleo')) {
      return Icons.work;
    } else if (serviceLower.contains('transporte')) {
      return Icons.directions_bus;
    } else {
      return Icons.place;
    }
  }
}
