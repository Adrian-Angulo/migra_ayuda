import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class EntityDetailInfo extends StatelessWidget {
  final EntityEntity entity;

  const EntityDetailInfo({
    super.key,
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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

          // Rating
          const _RatingWidget(),
          const SizedBox(height: 12),

          // Estado y horarios
          _ScheduleWidget(serviceHours: entity.serviceHours),
          const SizedBox(height: 12),

          // Servicios
          _ServicesWidget(services: entity.services),
          const SizedBox(height: 12),

          // Dirección
          _AddressWidget(address: entity.address),
          const SizedBox(height: 12),

          // Teléfono
          if (entity.phone.isNotEmpty) _PhoneWidget(phone: entity.phone),
          if (entity.phone.isNotEmpty) const SizedBox(height: 12),

          // Descripción
          if (entity.description.isNotEmpty)
            _DescriptionWidget(description: entity.description),
          if (entity.description.isNotEmpty) const SizedBox(height: 20),

          // Botón "Como llegar"
          _NavigationButton(
            latitude: entity.localitation.latitude,
            longitude: entity.localitation.longitude,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _RatingWidget extends StatelessWidget {
  const _RatingWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 24),
        const SizedBox(width: 8),
        const Text(
          '4.4',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          '(20)',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _ScheduleWidget extends StatelessWidget {
  final String serviceHours;

  const _ScheduleWidget({required this.serviceHours});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.access_time, color: Colors.green, size: 20),
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
              if (serviceHours.isNotEmpty)
                Text(
                  serviceHours,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServicesWidget extends StatelessWidget {
  final List<String> services;

  const _ServicesWidget({required this.services});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _getIconForService(services.isNotEmpty ? services.first : ''),
          color: Colors.orange,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Servicios: ${services.join(", ")}',
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
        ),
      ],
    );
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
    }
    return Icons.business;
  }
}

class _AddressWidget extends StatelessWidget {
  final String address;

  const _AddressWidget({required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _PhoneWidget extends StatelessWidget {
  final String phone;

  const _PhoneWidget({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.phone, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            phone,
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _DescriptionWidget extends StatelessWidget {
  final String description;

  const _DescriptionWidget({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _NavigationButton({
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _openNavigation(BuildContext context) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
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
}
