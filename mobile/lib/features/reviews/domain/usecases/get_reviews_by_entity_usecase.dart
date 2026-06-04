import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para obtener las reviews de una entidad específica
///
/// Filtra las reviews por ID de entidad
class GetReviewsByEntityUsecase {
  final ReviewRepository repository;
  GetReviewsByEntityUsecase({required this.repository});

  Future<Either<String, List<ReviewEntity>>> call(String entityId) async {
    // Delega al repositorio
    return await repository.getReviewsByEntity(entityId);
  }
}
