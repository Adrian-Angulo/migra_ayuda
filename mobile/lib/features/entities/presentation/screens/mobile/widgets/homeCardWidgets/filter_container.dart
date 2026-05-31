import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/constants.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/widgets/widgets.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/filter_providers.dart';

class FilterContainer extends ConsumerWidget {
  const FilterContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String selectedFiltro = ref.watch(seletedFilterProvider);
    return SingleChildScrollView(
      key: const PageStorageKey('scroll_horizontal_filtros'),
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 8.0, // Reemplaza al separatorBuilder
          children: services.map((service) {
            final isSelected = selectedFiltro == service;
            return FilterChip(
              avatar: Icon(getServiceIcon(service)),
              showCheckmark: false,
              label: Text(service),
              selected: isSelected,
              onSelected: (value) {
                if (value) {
                  ref.read(seletedFilterProvider.notifier).state = service;
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
