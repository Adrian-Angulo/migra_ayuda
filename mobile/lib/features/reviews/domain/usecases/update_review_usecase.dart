import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para actualizar una review existente
///
/// Valida los datos de entrada y delega la actualización al repositorio
class UpdateReviewUsecase {
  final ReviewRepository repository;

  UpdateReviewUsecase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// [review] - Review con los datos actualizados
  /// Retorna [Right(Unit)] si la actualización fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla la validación o actualización
  Future<Either<String, Unit>> call(ReviewEntity review) async {
    // Validación de datos
    final validationError = _validateReview(review);
    if (validationError != null) {
      return left(validationError);
    }

    // Crea una nueva instancia con updatedAt actualizado
    final updatedReview = ReviewEntity(
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
      isSynced: false, // Marca como no sincronizada
    );

    // Delega al repositorio
    return await repository.updateReview(updatedReview);
  }

  /// Valida los datos de la review
  ///
  /// Retorna [null] si la validación es exitosa
  /// Retorna [String] con el mensaje de error si falla
  String? _validateReview(ReviewEntity review) {
    // Valida que tenga ID
    if (review.id.trim().isEmpty) {
      return 'El ID de la review no puede estar vacío';
    }

    // Valida rating (debe estar entre 1 y 5)
    if (review.rating < 1 || review.rating > 5) {
      return 'El rating debe estar entre 1 y 5';
    }

    // Valida comentario (no debe estar vacío)
    if (review.comment.trim().isEmpty) {
      return 'El comentario no puede estar vacío';
    }

    // Valida longitud del comentario (mínimo 10 caracteres)
    if (review.comment.trim().length < 10) {
      return 'El comentario debe tener al menos 10 caracteres';
    }

    // Valida longitud del comentario (máximo 500 caracteres)
    if (review.comment.trim().length > 500) {
      return 'El comentario no puede exceder 500 caracteres';
    }

    // Valida que no esté eliminada
    if (review.deletedAt != null) {
      return 'No se puede actualizar una review eliminada';
    }

    return null; // Validación exitosa
  }
}
