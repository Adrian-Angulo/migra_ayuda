import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Future<Either<Failure, void>> createReview(ReviewEntity review);

  Future<Either<Failure, List<ReviewEntity>>> getReviewsByEntity(String entityId);

  Future<Either<Failure, List<ReviewEntity>>> getAllReviews();

  Future<Either<Failure, void>> updateReview(ReviewEntity review);

  Future<Either<Failure, void>> deleteReview(String reviewId);

  Future<Either<Failure, ReviewEntity?>> getUserReviewByEntity(
    String userId,
    String entityId,
  );

  Future<Either<Failure, void>> syncPendingReviews();
}
