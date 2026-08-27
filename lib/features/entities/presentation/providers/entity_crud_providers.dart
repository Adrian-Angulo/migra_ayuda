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

  Future<void> actualizarTotalYPromedioEntidad(String entidadId) async {
    final repository = ref.read(entityRepositoryProvider);

    // Obtener la entidad actual por ID
    final EntityEntity? entidad = await repository.getEntityById(entidadId);
    if (entidad == null) {
      throw Exception('Entidad no encontrada con el id: $entidadId');
    }

    // Obtener las reseñas relacionadas a la entidad
    final reviewRepo = ref.read(reviewRepositoryProvider);
    final List<ReviewEntity> reviews = await reviewRepo.getReviewsByEntity(entidadId);

    int totalReviews = reviews.length;
    double totalRating = reviews.fold(0.0, (sum, r) => sum + r.rating);
    double promedio = totalReviews > 0 ? totalRating / totalReviews : 0.0;

    // Actualizar los campos de la entidad (asumiendo que tiene campos para esto)
    final EntityEntity entidadActualizada = entidad.copyWith(
      totalReviews: totalReviews,
      averageRating: promedio,
    );

    await repository.updateEntity(entity: entidadActualizada);

    // Opcionalmente devolver o notificar el resultado si tu modelo lo requiere
  }
}

final entitiesCrudProvider =
    AsyncNotifierProvider<EntitiesCrudNotifier, CrudOperation>(
        EntitiesCrudNotifier.new);
