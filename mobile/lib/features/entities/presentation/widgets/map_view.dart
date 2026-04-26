import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

class MapView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FlutterMap(
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
        if (entities.isNotEmpty)
          MarkerLayer(
            markers: _buildMarkers(context),
          ),
      ],
    );
  }

  LatLng _getInitialCenter() {
    if (entities.isEmpty) {
      return const LatLng(1.2136, -77.2811); // Ubicación por defecto
    }

    // Calcula el centro basado en todas las entidades
    double totalLat = 0;
    double totalLng = 0;

    for (final entity in entities) {
      totalLat += entity.localitation.latitude;
      totalLng += entity.localitation.longitude;
    }

    return LatLng(
      totalLat / entities.length,
      totalLng / entities.length,
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
    return entities.map((entity) {
      final isSelected = selectedEntity?.id == entity.id;

      return Marker(
        point: LatLng(
          entity.localitation.latitude,
          entity.localitation.longitude,
        ),
        width: isSelected ? 60 : 50,
        height: isSelected ? 60 : 50,
        child: GestureDetector(
          onTap: () => onMarkerTap?.call(entity),
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
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 4,
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
                color: Colors.black.withOpacity(0.3),
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
