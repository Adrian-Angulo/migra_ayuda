import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/models/entities_datasource.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';



final searchControllerProvider = StateProvider<String>((ref) => '');


final seletedServiceProvider = StateProvider<String>((ref) => services[0]);

final selectedEntityProvider = StateProvider<EntityEntity?>((ref) => null);

final datasourceProvider = Provider<EntityDataSource>(
  (ref) => EntityDataSource(
    onRowSelected: (entity) {
      ref.read(selectedEntityProvider.notifier).state = entity;
    },
  ),
);


final queryEntityProvider = StateProvider<String>((ref) => '');


final selectedServiceFilterProvider =
    StateProvider<String>((ref) => services[0]);


final entitySortColumnProvider = StateProvider<int?>((ref) => null);


final entitySortAscendingProvider = StateProvider<bool>((ref) => true);


final entitiesFilterProvider =
    StateProvider.autoDispose<AsyncValue<List<EntityEntity>>>((ref) {
  final entitiesAsync = ref.watch(entities2StreamProvider);
  final query = ref.watch(queryEntityProvider);
  final service = ref.watch(selectedServiceFilterProvider);
  final sortColumn = ref.watch(entitySortColumnProvider);
  final ascending = ref.watch(entitySortAscendingProvider);

  return entitiesAsync.when(
    data: (list) {
      var filtered = list.where((e) {
        final matchText = query.isEmpty ||
            e.name.toLowerCase().contains(query) ||
            e.address.toLowerCase().contains(query);
        final matchService = service == 'Todos' || e.services.contains(service);
        return matchText && matchService;
      }).toList();

      if (sortColumn != null) {
        filtered.sort((a, b) {
          final valA = sortColumn == 0 ? a.name : a.address;
          final valB = sortColumn == 0 ? b.name : b.address;
          return ascending ? valA.compareTo(valB) : valB.compareTo(valA);
        });
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
