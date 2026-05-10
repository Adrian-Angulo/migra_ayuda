import 'package:flutter/material.dart';

class ServiceTypeChecklistWidget extends StatelessWidget {
  final List<String> selectedServices;
  final ValueChanged<List<String>> onServicesChanged;

  const ServiceTypeChecklistWidget({
    super.key,
    required this.selectedServices,
    required this.onServicesChanged,
  });

  static const List<Map<String, dynamic>> serviceTypes = [
    {
      'name': 'Asistencia medica',
      'icon': Icons.local_hospital,
      'color': Color(0xFFEF4444),
    },

    {'name': 'Alojamiento', 'icon': Icons.home, 'color': Color(0xFF8B5CF6)},
    {'name': 'Empleo temporal', 'icon': Icons.work, 'color': Color(0xFF10B981)},
    {
      'name': 'Alimentación',
      'icon': Icons.restaurant,
      'color': Color(0xFFEC4899),
    },
    {
      'name': 'Transporte',
      'icon': Icons.directions_bus,
      'color': Color(0xFF06B6D4),
    },
    {
      'name': 'Documentación',
      'icon': Icons.description,
      'color': Color(0xFF6366F1),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 30,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: serviceTypes.length,
      itemBuilder: (context, index) {
        final service = serviceTypes[index];
        final isSelected = selectedServices.contains(service['name']);

        return InkWell(
          onTap: () {
            final newSelectedServices = List<String>.from(selectedServices);
            if (isSelected) {
              newSelectedServices.remove(service['name']);
            } else {
              newSelectedServices.add(service['name']);
            }
            onServicesChanged(newSelectedServices);
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (service['color'] as Color).withOpacity(0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (service['color'] as Color)
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  service['icon'] as IconData,
                  size: 32,
                  color: isSelected
                      ? (service['color'] as Color)
                      : Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  service['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? (service['color'] as Color)
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: service['color'] as Color,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
