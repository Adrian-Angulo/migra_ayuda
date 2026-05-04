import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para crear una nueva review
///
/// Valida los datos de entrada y delega la creación al repositorio
class CreateReviewUsecase {
  final ReviewRepository repository;

  CreateReviewUsecase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// [review] - Review a crear
  /// Retorna [Right(Unit)] si la creación fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla la validación o creación
  Future<Either<String, Unit>> call(ReviewEntity review) async {
    // Validación de datos
    final validationError = _validateReview(review);
    if (validationError != null) {
      return left(validationError);
    }

    // Delega al repositorio
    return await repository.createReview(review);
  }

  /// Valida los datos de la review
  ///
  /// Retorna [null] si la validación es exitosa
  /// Retorna [String] con el mensaje de error si falla
  String? _validateReview(ReviewEntity review) {
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

    // Valida que tenga ID de entidad
    if (review.idEntity.trim().isEmpty) {
      return 'Debe especificar la entidad a revisar';
    }

    // Valida que tenga ID de migrante
    if (review.idMigrante.trim().isEmpty) {
      return 'Debe especificar el usuario que crea la review';
    }

    // Valida nombre de usuario
    if (review.userName.trim().isEmpty) {
      return 'El nombre de usuario no puede estar vacío';
    }

    // Valida país de usuario
    if (review.userCountry.trim().isEmpty) {
      return 'El país del usuario no puede estar vacío';
    }

    return null; // Validación exitosa
  }
}
