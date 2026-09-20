import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase(this.repository);

  Future<Either<Failure, void>> call(ReviewEntity review) {
    return repository.createReview(review);
  }
}

class GetReviewsByEntityUseCase {
  final ReviewRepository repository;

  GetReviewsByEntityUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call(String entityId) {
    return repository.getReviewsByEntity(entityId);
  }
}

class GetAllReviewsUseCase {
  final ReviewRepository repository;

  GetAllReviewsUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call() {
    return repository.getAllReviews();
  }
}

class UpdateReviewUseCase {
  final ReviewRepository repository;

  UpdateReviewUseCase(this.repository);

  Future<Either<Failure, void>> call(ReviewEntity review) {
    return repository.updateReview(review);
  }
}

class DeleteReviewUseCase {
  final ReviewRepository repository;

  DeleteReviewUseCase(this.repository);

  Future<Either<Failure, void>> call(String reviewId) {
    return repository.deleteReview(reviewId);
  }
}

class GetUserReviewByEntityUseCase {
  final ReviewRepository repository;

  GetUserReviewByEntityUseCase(this.repository);

  Future<Either<Failure, ReviewEntity?>> call(String userId, String entityId) {
    return repository.getUserReviewByEntity(userId, entityId);
  }
}

class SyncPendingReviewsUseCase {
  final ReviewRepository repository;

  SyncPendingReviewsUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.syncPendingReviews();
  }
}