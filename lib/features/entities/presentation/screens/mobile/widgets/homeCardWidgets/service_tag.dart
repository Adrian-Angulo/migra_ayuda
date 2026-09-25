import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';

class ServiceTag extends StatelessWidget {
  final String label;

  const ServiceTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = getServiceColor(label);
    final icon = getServiceIcon(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color[700] ?? color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color[800] ?? color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}