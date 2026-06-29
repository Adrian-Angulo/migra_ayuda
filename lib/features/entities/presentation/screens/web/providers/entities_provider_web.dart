import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';

final entities2StreamProvider = StreamProvider<List<EntityEntity>>(
  (ref) {
    final repo = ref.watch(entityRepositoryProvider);
    final res = repo.getAllEntites2();
    return res.map((either) => either.fold(
          (error) => throw Exception(error),
          (entities) => entities,
        ));
  },
);

class EntitiesProviderWeb extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> agregarEntidad(
    entity,
    imagenBytes,
    fileName,
  ) async {
    state = const AsyncValue.loading();
    final agregarEntidad = ref.read(registerEntityUsecaseProvider);
    final result = await agregarEntidad(entity, imagenBytes, fileName);

    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> editarEntidad(
    entity,
    imagenBytes,
    fileName,
  ) async {
    state = const AsyncValue.loading();
    final editarEntidad = ref.read(updateEntityUsecaseProvider);
    final result = await editarEntidad(
        entity: entity, imagenBytes: imagenBytes, fileName: fileName);

    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> eliminarEntidad(String entityId) async {
    state = const AsyncValue.loading();
    final eliminarEntidad = ref.read(deleteEntityUsecaseProvider);
    final result = await eliminarEntidad(entityId);

    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}
