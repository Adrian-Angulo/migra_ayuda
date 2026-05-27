import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/constants/constants.dart';

// SOLID: Single Responsibility - Widget solo para mostrar chips de servicios
class ServiceChip extends StatelessWidget {
  final String service;

  const ServiceChip({
    super.key,
    required this.service,
  });



  @override
  Widget build(BuildContext context) {
    final color = getServiceColor(service);

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
            getServiceIcon(service),
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
