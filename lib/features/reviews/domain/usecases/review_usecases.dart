import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase(this.repository);

  Future<void> call(ReviewEntity review) {
    return repository.createReview(review);
  }
}

class GetReviewsByEntityUseCase {
  final ReviewRepository repository;

  GetReviewsByEntityUseCase(this.repository);

  Future<List<ReviewEntity>> call(String entityId) {
    return repository.getReviewsByEntity(entityId);
  }
}

class GetAllReviewsUseCase {
  final ReviewRepository repository;

  GetAllReviewsUseCase(this.repository);

  Future<List<ReviewEntity>> call() {
    return repository.getAllReviews();
  }
}

class UpdateReviewUseCase {
  final ReviewRepository repository;

  UpdateReviewUseCase(this.repository);

  Future<void> call(ReviewEntity review) {
    return repository.updateReview(review);
  }
}

class DeleteReviewUseCase {
  final ReviewRepository repository;

  DeleteReviewUseCase(this.repository);

  Future<void> call(String reviewId) {
    return repository.deleteReview(reviewId);
  }
}

class GetUserReviewByEntityUseCase {
  final ReviewRepository repository;

  GetUserReviewByEntityUseCase(this.repository);

  Future<ReviewEntity?> call(String userId, String entityId) {
    return repository.getUserReviewByEntity(userId, entityId);
  }
}

class SyncPendingReviewsUseCase {
  final ReviewRepository repository;

  SyncPendingReviewsUseCase(this.repository);

  Future<void> call() {
    return repository.syncPendingReviews();
  }
}