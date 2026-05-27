import 'package:flutter/material.dart';

// SOLID: Single Responsibility - Widget solo para mostrar chips de servicios
class ServiceChip extends StatelessWidget {
  final String service;

  const ServiceChip({
    super.key,
    required this.service,
  });

  MaterialColor _getServiceColor(String service) {
    switch (service.toLowerCase()) {
      case 'legal':
        return Colors.blue;
      case 'salud':
        return Colors.green;
      case 'vivienda':
        return Colors.orange;
      case 'trabajo':
        return Colors.purple;
      case 'educación':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'legal':
        return Icons.gavel;
      case 'salud':
        return Icons.local_hospital;
      case 'vivienda':
        return Icons.home;
      case 'trabajo':
        return Icons.work;
      case 'educación':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getServiceColor(service);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getServiceIcon(service),
            size: 12,
            color: color[700],
          ),
          const SizedBox(width: 4),
          Text(
            service,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color[700],
            ),
          ),
        ],
      ),
    );
  }
}
