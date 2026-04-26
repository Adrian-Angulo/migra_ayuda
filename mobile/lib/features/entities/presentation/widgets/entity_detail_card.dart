import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/widgets/cached_image_widget.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class EntityDetailCard extends StatelessWidget {
  final EntityEntity entity;
  final VoidCallback onClose;

  const EntityDetailCard({
    super.key,
    required this.entity,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de arrastre
          Center(
            child: Container(
              width: 60,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen con botón de cerrar
                  _buildImageHeader(context),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre de la entidad
                        Text(
                          entity.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Rating (simulado por ahora)
                        _buildRating(),
                        const SizedBox(height: 12),

                        // Estado y horarios
                        _buildSchedule(),
                        const SizedBox(height: 12),

                        // Servicios
                        _buildServices(),
                        const SizedBox(height: 12),

                        // Dirección
                        _buildAddress(),
                        const SizedBox(height: 12),

                        // Teléfono
                        if (entity.phone.isNotEmpty) _buildPhone(),
                        if (entity.phone.isNotEmpty) const SizedBox(height: 12),

                        // Descripción
                        if (entity.description.isNotEmpty) _buildDescription(),
                        if (entity.description.isNotEmpty)
                          const SizedBox(height: 20),

                        // Botón "Como llegar"
                        _buildNavigationButton(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return Stack(
      children: [
        // Imagen
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: entity.imageUrl.isNotEmpty
              ? CachedImageWidget(
                  imageUrl: entity.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
        ),

        // Botón cerrar
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 24,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(
          Icons.star,
          color: Colors.amber,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          '4.4',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(20)',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSchedule() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.access_time,
          color: Colors.green,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Abierto ahora',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (entity.serviceHours.isNotEmpty)
                Text(
                  entity.serviceHours,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServices() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _getIconForService(
              entity.services.isNotEmpty ? entity.services.first : ''),
          color: Colors.orange,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Servicios: ${entity.services.join(", ")}',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on,
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            entity.address,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhone() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.phone,
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            entity.phone,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entity.description,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _openNavigation(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ECDC4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Como llegar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _openNavigation(BuildContext context) async {
    final lat = entity.localitation.latitude;
    final lng = entity.localitation.longitude;

    // URL para Google Maps
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir la navegación'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir navegación: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
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
      return Icons.business;
    }
  }
}
