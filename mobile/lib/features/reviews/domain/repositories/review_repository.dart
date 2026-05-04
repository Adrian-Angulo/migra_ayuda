import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';

/// Repositorio abstracto para manejar las operaciones de reviews
/// Sigue el patrón Repository de Clean Architecture
abstract class ReviewRepository {
  /// Crea una nueva review
  ///
  /// Retorna [Right(Unit)] si la operación fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, Unit>> createReview(ReviewEntity review);

  /// Obtiene todas las reviews de una entidad específica
  ///
  /// [entityId] - ID de la entidad para filtrar las reviews
  /// Retorna [Right(List<ReviewEntity>)] con las reviews encontradas
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, List<ReviewEntity>>> getReviewsByEntity(
      String entityId);

  /// Obtiene todas las reviews del sistema
  ///
  /// Retorna [Right(List<ReviewEntity>)] con todas las reviews
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, List<ReviewEntity>>> getAllReviews();

  /// Actualiza una review existente
  ///
  /// [review] - Review con los datos actualizados
  /// Retorna [Right(Unit)] si la operación fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, Unit>> updateReview(ReviewEntity review);

  /// Elimina una review (soft delete)
  ///
  /// [reviewId] - ID de la review a eliminar
  /// Retorna [Right(Unit)] si la operación fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, Unit>> deleteReview(String reviewId);

  /// Obtiene la review de un usuario específico en una entidad
  ///
  /// [userId] - ID del usuario (migrante)
  /// [entityId] - ID de la entidad
  /// Retorna [Right(ReviewEntity?)] con la review si existe, o null si no existe
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, ReviewEntity?>> getUserReviewByEntity(
    String userId,
    String entityId,
  );

  /// Sincroniza las reviews pendientes con el servidor
  ///
  /// Sube las reviews que tienen isSynced=false
  /// Retorna [Right(Unit)] si la sincronización fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, Unit>> syncPendingReviews();
}
