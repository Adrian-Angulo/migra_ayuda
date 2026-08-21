import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/providers/form_add_providers.dart';

/// Widget para mostrar una lista de servicios en formato de checklist,
/// permitiendo seleccionar hasta dos servicios.
class ServiceTypeChecklistWidget extends ConsumerStatefulWidget {
  const ServiceTypeChecklistWidget({
    super.key,
  });

  @override
  ConsumerState<ServiceTypeChecklistWidget> createState() =>
      _ServiceTypeChecklistWidgetState();
}

class _ServiceTypeChecklistWidgetState
    extends ConsumerState<ServiceTypeChecklistWidget> {
  // Lista local para almacenar servicios seleccionados por el usuario
  final List<String> selectedServices = [];

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      // Cuando se guarda el formulario, se actualiza el provider global
      onSaved: (newValue) {
        ref.read(listSelectedServicesFormProviders.notifier).state =
            selectedServices;
      },
      initialValue: selectedServices,
      // Validador para requerir al menos un servicio seleccionado
      validator: (value) {
        if (value!.isEmpty) return 'Debe seleccionar almenos un servicio';
        
        return null;
      },
      builder: (field) {
        return Column(
          children: [
            // Muestra los servicios disponibles en una grilla
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: kIsWeb ? 5 : 3, // Número de columnas según plataforma
                crossAxisSpacing: kIsWeb ? 20 : 5, // Espacio horizontal entre ítems
                mainAxisSpacing: 12, // Espacio vertical entre ítems
                childAspectRatio: 1.2, // Relación de aspecto de cada ítem
              ),
              // El primer servicio (index 0) no se muestra (por lógica del negocio)
              itemCount: services.length - 1,
              itemBuilder: (context, index) {
                final service = services[index + 1];
                // Determinar si el servicio está seleccionado
                final isSelected = selectedServices.contains(service);

                return InkWell(
                  // Al tocar, selecciona o deselecciona el servicio
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        // Si ya está seleccionado, se quita
                        selectedServices.remove(service);
                      } else {
                        // Si hay menos de dos seleccionados, se añade
                        if (selectedServices.length <= 1) {
                          selectedServices.add(service);
                        }
                      }
                    });
                    // Notifica al FormField que hubo un cambio
                    field.didChange(selectedServices);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          // Si está seleccionado, muestra un color relacionado y opaco
                          ? (getServiceColor(service) as Color)
                              .withValues(alpha: 0.1)
                          // Si no, fondo gris claro
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
                        // Icono representando al servicio
                        Icon(
                          getServiceIcon(service),
                          size: 32,
                          color: isSelected
                              ? getServiceColor(service)
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        // Nombre del servicio
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
            // Si hay error de validación, se muestra en texto rojo
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
