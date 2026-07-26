import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entities_datasource.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';


final searchControllerProvider = StateProvider<String>(
  (ref) => "",
);

final seletedServiceProvider = StateProvider<String>(
  (ref) => services[0],
);

// Provider para manejar la entidad seleccionada
final selectedEntityProvider = StateProvider<EntityEntity?>(
  (ref) => null,
);

final datasourceProvider = Provider<EntityDataSource>(
  (ref) {
    return EntityDataSource(
      onRowSelected: (entity) {
        ref.read(selectedEntityProvider.notifier).state = entity;
        
      },
    );
  },
);
