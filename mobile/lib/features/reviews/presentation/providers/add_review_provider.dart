import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/states/create_review_state.dart';

/// Notifier para manejar el estado de creación de reviews
class AddReviewNotifier extends Notifier<CreateReviewState> {
  @override
  CreateReviewState build() {
    return CreateReviewState();
  }

  /// Crea una nueva review
  Future<void> createReview({
    required String idMigrante,
    required String idEntity,
    required String userName,
    required String userCountry,
    required double rating,
    required String comment,
  }) async {
    // Cambia a estado de carga
    state =
        state.copyWith(isLoading: true, isSucces: false, errorMensaje: null);

    try {
      // Crea la entidad de review
      final review = ReviewEntity(
        id: '', // Se generará automáticamente en el repository
        idMigrante: idMigrante,
        idEntity: idEntity,
        userName: userName,
        userCountry: userCountry,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        updatedAt: null,
        deletedAt: null,
        isSynced: false,
      );

      // Obtiene el use case
      final createReviewUsecase = ref.read(createReviewUsecaseProvider);

      // Ejecuta el caso de uso
      final result = await createReviewUsecase.call(review);

      // Maneja el resultado
      result.fold(
        (error) {
          // Error
          state = state.copyWith(
            isLoading: false,
            isSucces: false,
            errorMensaje: error,
          );
        },
        (_) {
          // Éxito
          state = state.copyWith(
            isLoading: false,
            isSucces: true,
            errorMensaje: null,
          );

          // Invalida el stream provider para actualizar la lista
          ref.invalidate(reviewsByEntityStreamProvider(idEntity));
        },
      );
    } catch (e) {
      // Error inesperado
      state = state.copyWith(
        isLoading: false,
        isSucces: false,
        errorMensaje: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Resetea el estado
  void reset() {
    state = CreateReviewState();
  }
}

/// Provider del notifier de agregar review
final addReviewProvider =
    NotifierProvider<AddReviewNotifier, CreateReviewState>(
  AddReviewNotifier.new,
);
