import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para obtener la review de un usuario específico en una entidad
///
/// Retorna la review si existe, o null si el usuario no ha hecho review en esa entidad
class GetUserReviewByEntityUsecase {
  final ReviewRepository repository;

  GetUserReviewByEntityUsecase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// [userId] - ID del usuario (migrante)
  /// [entityId] - ID de la entidad
  /// Retorna [Right(ReviewEntity?)] con la review si existe, o null si no existe
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, ReviewEntity?>> call(
    String userId,
    String entityId,
  ) async {
    // Valida que los IDs no estén vacíos
    if (userId.trim().isEmpty) {
      return left('El ID del usuario no puede estar vacío');
    }

    if (entityId.trim().isEmpty) {
      return left('El ID de la entidad no puede estar vacío');
    }

    // Delega al repositorio
    return await repository.getUserReviewByEntity(userId, entityId);
  }
}
