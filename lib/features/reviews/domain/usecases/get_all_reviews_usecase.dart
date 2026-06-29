import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para obtener todas las reviews del sistema
///
/// Útil para administración o estadísticas generales
class GetAllReviewsUsecase {
  final ReviewRepository repository;

  GetAllReviewsUsecase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// Retorna [Right(List<ReviewEntity>)] con todas las reviews activas
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, List<ReviewEntity>>> call() async {
    // Delega al repositorio
    final result = await repository.getAllReviews();

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

  /// Obtiene todas las reviews incluyendo las eliminadas
  ///
  /// Útil para administración o auditoría
  /// Retorna [Right(List<ReviewEntity>)] con todas las reviews
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, List<ReviewEntity>>> callIncludingDeleted() async {
    final result = await repository.getAllReviews();

    // Ordena por fecha sin filtrar eliminadas
    return result.map((reviews) {
      return reviews..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }
}
