import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para actualizar una review existente
///
/// Valida los datos de entrada y delega la actualización al repositorio
class UpdateReviewUsecase {
  final ReviewRepository repository;

  UpdateReviewUsecase({required this.repository});

  Future<Either<String, Unit>> call(ReviewEntity review) async {
    // Crea una nueva instancia con updatedAt actualizado

    final updateReview =
        review.copyWith(updatedAt: DateTime.now(), isSynced: false);

/*     final updatedReview = ReviewEntity(
      id: review.id,
      idMigrante: review.idMigrante,
      idEntity: review.idEntity,
      userName: review.userName,
      userCountry: review.userCountry,
      rating: review.rating,
      comment: review.comment,
      createdAt: review.createdAt,
      updatedAt: DateTime.now(), // Actualiza la fecha de modificación
      deletedAt: review.deletedAt,
      isSynced: false,
      nameEntity: review.nameEntity, // Marca como no sincronizada
    );
 */
    // Delega al repositorio
    return await repository.updateReview(updateReview);
  }
}
