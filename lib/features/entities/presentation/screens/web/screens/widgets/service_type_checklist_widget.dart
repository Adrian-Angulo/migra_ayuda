import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/providers/form_add_providers.dart';

class ServiceTypeChecklistWidget extends ConsumerStatefulWidget {

  const ServiceTypeChecklistWidget({
    super.key,
  });

  @override
  ConsumerState<ServiceTypeChecklistWidget> createState() => _ServiceTypeChecklistWidgetState();
}

class _ServiceTypeChecklistWidgetState extends ConsumerState<ServiceTypeChecklistWidget> {
  final List<String> selectedServices =  [];

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      onSaved: (listService) {
         ref.read(selectServiceProvider.notifier).state = selectedServices; 
      },
      initialValue: selectedServices,
                validator: (value) {
                  if(value!.isEmpty) return 'Debe seleccionar almenos un servicio';
                  /* ref.read(selectServiceProvider.notifier).state = selectedServices; */
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
                /* final newSelectedServices = List<String>.from(selectedServices); */
                setState(() {
                  
                if (isSelected) {
                 
                  selectedServices.remove(service);
                } else {
                  if (selectedServices.length <= 1) {
                    selectedServices.add(service);
                   
                  }
                }
                });
                field.didChange(selectedServices);
              /*   onServicesChanged(newSelectedServices); */
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (getServiceColor(service) as Color).withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: field.hasError ? Border.all(color: Colors.red, width: 2) : Border.all(
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
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

                  if(field.hasError)
                  Text(field.errorText!, style: const TextStyle(color: Colors.red),)
          ],
        );
      },
    );
  }
}
