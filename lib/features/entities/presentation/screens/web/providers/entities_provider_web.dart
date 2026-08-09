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
    try {
      await repository.registerEntity(
        entity: entity,
        imagenBytes: imagenBytes,
        fileName: fileName,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> editarEntidad(
    entity,
    imagenBytes,
    fileName,
  ) async {
    state = const AsyncValue.loading();
    final repository = ref.read(entityRepositoryProvider);
    try {
      await repository.updateEntity(
        entity: entity,
        imagenBytes: imagenBytes,
        fileName: fileName,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> eliminarEntidad(String entityId) async {
    state = const AsyncValue.loading();
    final repository = ref.read(entityRepositoryProvider);
    try {
      await repository.deleteEntity(entityId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
