import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Future<void> createReview(ReviewEntity review);

  Future<List<ReviewEntity>> getReviewsByEntity(String entityId);

  Future<List<ReviewEntity>> getAllReviews();

  Future<void> updateReview(ReviewEntity review);

  Future<void> deleteReview(String reviewId);

  Future<ReviewEntity?> getUserReviewByEntity(
    String userId,
    String entityId,
  );

  /// Sincroniza las reviews pendientes con el servidor.
  ///
  /// Sube las reviews que tienen isSynced=false.
  Future<void> syncPendingReviews();
}
