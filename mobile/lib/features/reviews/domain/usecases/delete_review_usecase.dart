import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para eliminar una review (soft delete)
///
/// Marca la review como eliminada sin borrarla físicamente
class DeleteReviewUsecase {
  final ReviewRepository repository;

  DeleteReviewUsecase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// [reviewId] - ID de la review a eliminar
  /// Retorna [Right(Unit)] si la eliminación fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, Unit>> call(String reviewId) async {
    // Validación de entrada
    if (reviewId.trim().isEmpty) {
      return left('El ID de la review no puede estar vacío');
    }

    // Delega al repositorio
    return await repository.deleteReview(reviewId);
  }
}
