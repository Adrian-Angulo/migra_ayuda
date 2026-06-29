import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/constants/constants.dart';

class ServiceTypeChecklistWidget extends StatelessWidget {
  final List<String> selectedServices;
  final ValueChanged<List<String>> onServicesChanged;

  const ServiceTypeChecklistWidget({
    super.key,
    required this.selectedServices,
    required this.onServicesChanged,
  });

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
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = selectedServices.contains(service);

        return InkWell(
          onTap: () {
            final newSelectedServices = List<String>.from(selectedServices);
            if (isSelected) {
              newSelectedServices.remove(service);
            } else {
              newSelectedServices.add(service);
            }
            onServicesChanged(newSelectedServices);
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? (getServiceColor(service) as Color).withOpacity(0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (getServiceColor(service) as Color)
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  getServiceIcon(service),
                  size: 32,
                  color: isSelected
                      ? getServiceColor(service)
                      : Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  service,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? getServiceColor(service)
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: getServiceColor(service),
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
