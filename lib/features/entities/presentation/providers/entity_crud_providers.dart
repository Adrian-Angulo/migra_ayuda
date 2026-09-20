import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/usecases/entities_usecases.dart';
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

        final registerEntityUseCase = RegisterEntityUseCase(repository);
        final result = await registerEntityUseCase(
          entity: entity,
          imagenBytes: imagenBytes,
          fileName: fileName,
        );
        return result.fold(
          (failure) => throw failure,
          (_) => CrudOperation.register,
        );
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

      final updateEntityUseCase = UpdateEntityUseCase(repository);
      final result = await updateEntityUseCase(
        entity: entity,
        imagenBytes: imagenBytes,
        fileName: fileName,
      );
      return result.fold(
        (failure) => throw failure,
        (_) => CrudOperation.update,
      );
    });
  }

  Future<void> deleteEntity(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(entityRepositoryProvider);
      final deleteEntityUseCase = DeleteEntityUseCase(repository);

      final reviewR = ref.read(reviewRepositoryProvider);
      final reviewsResult = await reviewR.getReviewsByEntity(id);
      final List<ReviewEntity> reviews =
          reviewsResult.fold((_) => [], (r) => r);

      final result = await deleteEntityUseCase(id);
      return await result.fold(
        (failure) => throw failure,
        (_) async {
          await Future.wait(
            reviews.map((review) => reviewR.deleteReview(review.id)),
          );
          return CrudOperation.delete;
        },
      );
    });
  }

  Future<void> actualizarTotalYPromedioEntidad(String entidadId) async {
    final repository = ref.read(entityRepositoryProvider);
    final getEntityByIdUseCase = GetEntityByIdUseCase(repository);

    // Obtener la entidad actual por ID
    final entityResult = await getEntityByIdUseCase(entidadId);

    await entityResult.fold(
      (failure) => null,
      (entidad) async {
        // Obtener las reseñas relacionadas a la entidad
        final reviewRepo = ref.read(reviewRepositoryProvider);
        final reviewsResult =
            await reviewRepo.getReviewsByEntity(entidadId);
        final List<ReviewEntity> reviews =
            reviewsResult.fold((_) => [], (r) => r);

        int totalReviews = reviews.length;
        double totalRating = reviews.fold(0.0, (sum, r) => sum + r.rating);
        double promedio = totalReviews > 0 ? totalRating / totalReviews : 0.0;

        // Actualizar los campos de la entidad
        final EntityEntity entidadActualizada = entidad.copyWith(
          totalReviews: totalReviews,
          averageRating: promedio,
        );

        final updateEntityUseCase = UpdateEntityUseCase(repository);
        await updateEntityUseCase(entity: entidadActualizada);
      },
    );
  }
}

final entitiesCrudProvider =
    AsyncNotifierProvider<EntitiesCrudNotifier, CrudOperation>(
        EntitiesCrudNotifier.new);
