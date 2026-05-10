import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';



class EntityDetailNotifier extends AsyncNotifier<EntityEntity> {
  late String _entityId;

  @override
  FutureOr<EntityEntity> build() async {
    // El ID se establecerá mediante setEntityId antes de cargar
    return _cargar();
  }

  void setEntityId(String id) {
    _entityId = id;
  }

  Future<EntityEntity> _cargar() async {
    final usecase = ref.read(getEntityByIdUsecaseProvider);
    final result = await usecase(_entityId);

    return result.fold((error) => throw Exception(error), (entity) => entity);
  }

  Future<void> recargar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _cargar());
  }
}

final entityDetailNotifierProvider =
    AsyncNotifierProvider<EntityDetailNotifier, EntityEntity>(
  EntityDetailNotifier.new,
);
