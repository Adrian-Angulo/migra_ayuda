import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para obtener la review de un usuario específico en una entidad
///
/// Retorna la review si existe, o null si el usuario no ha hecho review en esa entidad
class GetUserReviewByEntityUsecase {
  final ReviewRepository repository;

  GetUserReviewByEntityUsecase({required this.repository});

  Future<Either<String, ReviewEntity?>> call(
    String userId,
    String entityId,
  ) async {
    return await repository.getUserReviewByEntity(userId, entityId);
  }
}
