import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/providers/form_add_providers.dart';

/// Widget para mostrar una lista de servicios en formato de checklist,
/// permitiendo seleccionar hasta dos servicios, usando el provider global.
class ServiceTypeChecklistWidget extends ConsumerWidget {
  const ServiceTypeChecklistWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> selectedServices = ref.watch(listSelectedServicesFormProviders);

    return FormField<List<String>>(
      // Cuando se guarda el formulario, se actualiza el provider global
      onSaved: (newValue) {
        ref.read(listSelectedServicesFormProviders.notifier).state =
            newValue ?? [];
      },
      initialValue: selectedServices,
      // Validador para requerir al menos un servicio seleccionado
      validator: (value) {
        if (value == null || value.isEmpty) return 'Debe seleccionar al menos un servicio';
        return null;
      },
      builder: (field) {
        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: kIsWeb ? 5 : 3,
                crossAxisSpacing: kIsWeb ? 20 : 5,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: services.length - 1,
              itemBuilder: (context, index) {
                final service = services[index + 1];
                final isSelected = selectedServices.contains(service);

                return InkWell(
                  onTap: () {
                    final notifier = ref.read(listSelectedServicesFormProviders.notifier);
                    final current = List<String>.from(ref.read(listSelectedServicesFormProviders));
                    if (isSelected) {
                      current.remove(service);
                    } else {
                      if (current.length < 2) {
                        current.add(service);
                      }
                    }
                    notifier.state = current;
                    field.didChange(current);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (getServiceColor(service) as Color).withOpacity(0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: field.hasError
                          ? Border.all(color: Colors.red, width: 2)
                          : Border.all(
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
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? getServiceColor(service)
                                : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (field.hasError)
              Text(
                field.errorText!,
                style: const TextStyle(color: Colors.red),
              )
          ],
        );
      },
    );
  }
}
