
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/get_all_entites_notifier.dart';


final seletedFilterProvider = StateProvider<String>(
  (ref) => 'Todos',
);
final listaEntidades = Provider<AsyncValue<List<EntityEntity>>>(
  (ref) {
    final entitiesAsync = ref.watch(getAllEntitiesNotifierProvider);
    final seletedService = ref.watch(seletedFilterProvider);

    return entitiesAsync.whenData(
      (data) {
        if (seletedService == 'Todos') return data;
        return data
            .where((enty) => enty.services.contains(seletedService))
            .toList();
      },
    );
    
  },
);
