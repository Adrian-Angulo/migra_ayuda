import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para crear una nueva review
///
/// Valida los datos de entrada y delega la creación al repositorio
class CreateReviewUsecase {
  final ReviewRepository repository;


  CreateReviewUsecase({required this.repository});


  Future<Either<String, Unit>> call(ReviewEntity review) async {
    // Verifica si el usuario ya tiene una review en esta entidad
    final existingReviewResult = await repository.getUserReviewByEntity(
      review.idMigrante,
      review.idEntity,
    );

    // Si hay error al verificar, continúa con la creación (no bloquea por error de verificación)
    final existingReview = existingReviewResult.fold(
      (error) => left(error.toString()), // Si hay error, asume que no existe
      (review) => review,
    );

    // Si ya existe una review, retorna error
    if (existingReview != null) {
      return left(
          'Ya has publicado una review en esta entidad. Puedes editarla o eliminarla.');
    }
    // Delega al repositorio
    return await repository.createReview(review);
  }
}
