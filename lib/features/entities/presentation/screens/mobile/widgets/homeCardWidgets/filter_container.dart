import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';

class FilterContainer extends ConsumerWidget {
  const FilterContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String selectedFiltro = ref.watch(filterProvider);
    return SingleChildScrollView(
      key: const PageStorageKey('scroll_horizontal_filtros'),
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 8.0,
          children: services.map((service) {
            final isSelected = selectedFiltro == service;
            return FilterChip(
              avatar: Icon(getServiceIcon(service)),
              showCheckmark: false,
              label: Text(getServicel10n(service, context)),
              selected: isSelected,
              onSelected: (value) async {
                if (value) {
                  ref
                      .read(getAllEntitiesProvider.notifier)
                      .filter(query: service);

                  await ref.read(auditNotifierProvider.notifier).create(
                      accion: ActivityActions.filter(),
                      metadata: {'filtro': service});
                  //limpiar entidad seleccionada al presionar filtro
                  ref.read(mapProvider.notifier).clearSelectEntity();
                  //limpiar la ruta
                  ref.read(mapProvider.notifier).clearRoute();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
