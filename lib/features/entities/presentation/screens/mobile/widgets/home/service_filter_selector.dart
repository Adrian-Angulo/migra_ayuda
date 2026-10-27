import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/map/presentation/providers/map_display_provider.dart';

class FilterActionCoordinator {
  final WidgetRef _ref;

  const FilterActionCoordinator(this._ref);

  Future<void> applyFilter(String service) async {
    _ref.read(getAllEntitiesProvider.notifier).filter(query: service);
    _ref.read(mapProvider.notifier).clearSelectEntity();
    _ref.read(mapProvider.notifier).clearRoute();

    if (service != 'Todos') {
      try {
        await _ref.read(auditNotifierProvider.notifier).create(
          accion: ActivityActions.filter(),
          metadata: {'filtro': service},
        );
      } catch (e) {
        debugPrint('Auditoría omitida: $e');
      }
    }
  }
}

class ServiceFilterSelector extends ConsumerWidget {
  const ServiceFilterSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFiltro = ref.watch(filterProvider);
    final isFiltered = selectedFiltro != 'Todos';
    final coordinator = FilterActionCoordinator(ref);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isFiltered ? theme.colorScheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  isFiltered ? theme.colorScheme.primary : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<String>(
                initialValue: selectedFiltro,
                tooltip: 'Seleccionar filtro',
                elevation: 6,
                offset: const Offset(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (service) => coordinator.applyFilter(service),
                itemBuilder: (context) {
                  return services.map((service) {
                    final isSelected = service == selectedFiltro;
                    final isDefaultAll = service == 'Todos';
                    final color = isDefaultAll
                        ? Colors.grey[700]!
                        : getServiceColor(service);
                    final icon = isDefaultAll
                        ? Icons.apps_rounded
                        : getServiceIcon(service);

                    return PopupMenuItem<String>(
                      value: service,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: color.withValues(alpha: 0.12),
                            child: Icon(icon, size: 16, color: color),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              service,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.grey[800],
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFiltered
                            ? getServiceIcon(selectedFiltro)
                            : Icons.tune_rounded,
                        size: 16,
                        color:
                            isFiltered ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedFiltro,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isFiltered ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color:
                            isFiltered ? Colors.white : Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
              if (isFiltered) ...[
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 14),
                  color: Colors.white,
                  tooltip: 'Quitar filtro',
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  constraints: const BoxConstraints(minWidth: 28),
                  onPressed: () => coordinator.applyFilter('Todos'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

typedef FilterContainer = ServiceFilterSelector;
