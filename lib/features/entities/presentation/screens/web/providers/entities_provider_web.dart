import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';



class EntitiesProviderWeb extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> agregarEntidad(
    entity,
    imagenBytes,
    fileName,
  ) async {
    state = const AsyncValue.loading();
    final repository = ref.read(entityRepositoryProvider);
    final result = await repository.registerEntity(
      entity: entity,
      imagenBytes: imagenBytes,
      fileName: fileName,
    );

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
    final repository = ref.read(entityRepositoryProvider);
    final result = await repository.updateEntity(
      entity: entity,
      imagenBytes: imagenBytes,
      fileName: fileName,
    );

    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> eliminarEntidad(String entityId) async {
    state = const AsyncValue.loading();
    final repository = ref.read(entityRepositoryProvider);
    final result = await repository.deleteEntity(entityId);

    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}
