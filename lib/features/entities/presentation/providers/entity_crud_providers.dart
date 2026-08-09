import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';

enum CrudOperation { register, update, delete, none }

class EntitiesCrudNotifier extends AsyncNotifier<CrudOperation> {
  @override
  FutureOr<CrudOperation> build() {
    return CrudOperation.none;
  }

  Future<void> registerEntity({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        final repository = ref.read(entityRepositoryProvider);
        await repository.registerEntity(
            entity: entity, imagenBytes: imagenBytes, fileName: fileName);
        return CrudOperation.register;
      },
    );
  }

  Future<void> updateEntity({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  }) async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(milliseconds: 500));

    state = await AsyncValue.guard(() async {
      final repository = ref.read(entityRepositoryProvider);
      await repository.updateEntity(
        entity: entity,
        imagenBytes: imagenBytes,
        fileName: fileName,
      );
      return CrudOperation.update;
    });
  }

  Future<void> deleteEntity(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(entityRepositoryProvider);
      await repository.deleteEntity(id);
      return CrudOperation.delete;
    });
  }

  Future<void> updateRating(double value) async {
    state = const AsyncValue.loading();
  }
}

final entitiesCrudProvider =
    AsyncNotifierProvider<EntitiesCrudNotifier, CrudOperation>(
        EntitiesCrudNotifier.new);
