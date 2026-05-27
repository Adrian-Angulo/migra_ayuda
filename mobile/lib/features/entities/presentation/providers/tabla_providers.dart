import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/core/constants/constants.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/tabla.dart';
import 'package:path/path.dart';

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
        // TODO: Aquí se implementará la acción al seleccionar una fila
        ref.read(selectedEntityProvider.notifier).state = entity;
        // Por ahora solo guardamos la entidad seleccionada
        print('Entidad seleccionada: ${entity.name}');
      },
    );
  },
);
