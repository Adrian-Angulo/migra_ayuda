import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/states/edit_review_state.dart';

/// Notifier para manejar el estado de edición y eliminación de reviews
class EditReviewNotifier extends Notifier<EditReviewState> {
  @override
  EditReviewState build() {
    return EditReviewState();
  }

  /// Actualiza una review existente
  Future<void> updateReview({
    required String reviewId,
    required String idMigrante,
    required String idEntity,
    required String userName,
    required String userCountry,
    required double rating,
    required String comment,
    required DateTime createdAt,
  }) async {
    // Cambia a estado de carga
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );

    try {
      // Crea la entidad de review actualizada
      final review = ReviewEntity(
        id: reviewId,
        idMigrante: idMigrante,
        idEntity: idEntity,
        userName: userName,
        userCountry: userCountry,
        rating: rating,
        comment: comment,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        deletedAt: null,
        isSynced: false,
      );

      // Obtiene el use case
      final updateReviewUsecase = ref.read(updateReviewUsecaseProvider);

      // Ejecuta el caso de uso
      final result = await updateReviewUsecase.call(review);

      // Maneja el resultado
      result.fold(
        (error) {
          // Error
          state = state.copyWith(
            isLoading: false,
            isSuccess: false,
            errorMessage: error,
          );
        },
        (_) {
          // Éxito
          state = state.copyWith(
            isLoading: false,
            isSuccess: true,
            errorMessage: null,
          );

          // Invalida los providers para actualizar la lista
          ref.invalidate(reviewsByEntityStreamProvider(idEntity));
          ref.invalidate(userReviewByEntityProvider(
              (userId: idMigrante, entityId: idEntity)));
        },
      );
    } catch (e) {
      // Error inesperado
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Elimina una review
  Future<void> deleteReview({
    required String reviewId,
    required String idMigrante,
    required String idEntity,
  }) async {
    // Cambia a estado de carga
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );

    try {
      // Obtiene el use case
      final deleteReviewUsecase = ref.read(deleteReviewUsecaseProvider);

      // Ejecuta el caso de uso
      final result = await deleteReviewUsecase.call(reviewId);

      // Maneja el resultado
      result.fold(
        (error) {
          // Error
          state = state.copyWith(
            isLoading: false,
            isSuccess: false,
            errorMessage: error,
          );
        },
        (_) {
          // Éxito
          state = state.copyWith(
            isLoading: false,
            isSuccess: true,
            errorMessage: null,
          );

          // Invalida los providers para actualizar la lista
          ref.invalidate(reviewsByEntityStreamProvider(idEntity));
          ref.invalidate(userReviewByEntityProvider(
              (userId: idMigrante, entityId: idEntity)));
        },
      );
    } catch (e) {
      // Error inesperado
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Resetea el estado
  void reset() {
    state = EditReviewState();
  }
}

/// Provider del notifier de editar review
final editReviewProvider =
    NotifierProvider<EditReviewNotifier, EditReviewState>(
  EditReviewNotifier.new,
);
