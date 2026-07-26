import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';

// SOLID: Single Responsibility - Widget solo para mostrar chips de servicios
class ServiceChip extends StatelessWidget {
  final String service;

  const ServiceChip({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getServiceIcon(service),
            size: 18,
            color: color[700],
          ),
          const SizedBox(width: 4),
          Text(
            service,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
