import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';

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
      final reviewR = ref.read(reviewRepositoryProvider);
      final List<ReviewEntity> reviews = await reviewR.getReviewsByEntity(id);
      await repository.deleteEntity(id);
      await Future.wait(
        reviews.map((review) => reviewR.deleteReview(review.id)),
      );
      return CrudOperation.delete;
    });
  }
}

final entitiesCrudProvider =
    AsyncNotifierProvider<EntitiesCrudNotifier, CrudOperation>(
        EntitiesCrudNotifier.new);
