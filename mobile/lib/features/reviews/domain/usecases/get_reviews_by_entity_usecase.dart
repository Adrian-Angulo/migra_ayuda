import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para obtener las reviews de una entidad específica
///
/// Filtra las reviews por ID de entidad
class GetReviewsByEntityUsecase {
  final ReviewRepository repository;

  GetReviewsByEntityUsecase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// [entityId] - ID de la entidad para filtrar las reviews
  /// Retorna [Right(List<ReviewEntity>)] con las reviews encontradas
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, List<ReviewEntity>>> call(String entityId) async {
    // Validación de entrada
    if (entityId.trim().isEmpty) {
      return left('El ID de la entidad no puede estar vacío');
    }

    // Delega al repositorio
    final result = await repository.getReviewsByEntity(entityId);

    // Filtra reviews eliminadas (deletedAt != null) y ordena por fecha
    return result.map((reviews) {
      final activeReviews = reviews
          .where((review) => review.deletedAt == null)
          .toList()
        ..sort((a, b) =>
            b.createdAt.compareTo(a.createdAt)); // Más recientes primero

      return activeReviews;
    });
  }
}
