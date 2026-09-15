import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';

/// Coordinador de acciones de filtrado (Principio de Responsabilidad Única - SRP).
/// Encapsula la lógica de negocio: filtrar entidades, registrar auditoría y limpiar estado en el mapa.
class FilterActionCoordinator {
  final WidgetRef _ref;

  const FilterActionCoordinator(this._ref);

  Future<void> applyFilter(String service) async {
    // 1. Aplicar filtro a las entidades (actualiza lista y notifica)
    _ref.read(getAllEntitiesProvider.notifier).filter(query: service);

    // 2. Filtrar los marcadores/puntos del mapa de forma inmediata
    final filteredEntities = _ref.read(getAllEntitiesProvider).value ?? [];
    await _ref.read(mapProvider.notifier).addMarkers(filteredEntities);

    // 3. Registrar auditoría solo si es un filtro específico
    if (service != 'Todos') {
      await _ref.read(auditNotifierProvider.notifier).create(
        accion: ActivityActions.filter(),
        metadata: {'filtro': service},
      );
    }

    // 4. Limpiar selección y ruta en el mapa
    _ref.read(mapProvider.notifier).clearSelectEntity();
    _ref.read(mapProvider.notifier).clearRoute();
  }
}

/// Botón de filtro con menú desplegable emergente (Opción 2 - PopupMenuButton).
/// Mantiene la firma pública [FilterContainer] para respetar compatibilidad (LSP).
class FilterContainer extends ConsumerWidget {
  const FilterContainer({super.key});

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
                            child: Icon(icon, color: color, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              service,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.black87,
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
                  padding: EdgeInsets.only(
                    left: 12.0,
                    top: 8.0,
                    bottom: 8.0,
                    right: isFiltered ? 4.0 : 12.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFiltered
                            ? getServiceIcon(selectedFiltro)
                            : Icons.tune_rounded,
                        size: 18,
                        color: isFiltered ? Colors.white : Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFiltered ? selectedFiltro : 'Filtrar por servicio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isFiltered ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 20,
                        color: isFiltered ? Colors.white70 : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              if (isFiltered)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => coordinator.applyFilter('Todos'),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
