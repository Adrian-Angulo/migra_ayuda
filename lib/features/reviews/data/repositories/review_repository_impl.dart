import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/core/network/network_info.dart';
import 'package:migra_ayuda/features/reviews/data/datasources/review_local_datasource.dart';
import 'package:migra_ayuda/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:migra_ayuda/features/reviews/data/models/review_model.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/failures/review_failures.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';
import 'package:uuid/uuid.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;
  final ReviewLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ReviewRepositoryImpl({
    required ReviewRemoteDataSource remoteDataSource,
    required ReviewLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> createReview(ReviewEntity review) async {
    try {
      final localId = const Uuid().v4();
      final reviewModel = ReviewModel.fromReviewEntity(review).copyWith(id: localId);
      await _localDataSource.cacheReview(reviewModel);
      return const Right(null);
    } catch (_) {
      return const Left(ReviewCreationFailedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByEntity(String entityId) async {
    try {
      final cachedReviews = await _localDataSource.getReviewsByEntity(entityId);
      final reviewEntities = cachedReviews.map((reviewModel) => reviewModel.toEntity()).toList();
      return Right(reviewEntities);
    } catch (error) {
      return const Left(ReviewFetchFailedFailure());
    }
  }


  @override
  Future<Either<Failure, List<ReviewEntity>>> getAllReviews() async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteReviews = await _remoteDataSource.getAllReviews();
          await _localDataSource.cacheReviews(remoteReviews);
          return Right(remoteReviews.map((r) => r.toEntity()).toList());
        } on ServerException {
          
        }
      }

      final cachedReviews = await _localDataSource.getCachedReviews();
      return Right(cachedReviews.map((r) => r.toEntity()).toList());
    } catch (_) {
      return const Left(ReviewFetchFailedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateReview(ReviewEntity review) async {
    try {
      final updatedModel = ReviewModel.fromReviewEntity(
        review,
        isSynced: false,
      ).copyWith(updatedAt: DateTime.now());

      await _localDataSource.cacheReview(updatedModel);
      return const Right(null);
    } catch (_) {
      return const Left(ReviewUpdateFailedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      await _localDataSource.deleteReview(reviewId);
      return const Right(null);
    } catch (_) {
      return const Left(ReviewDeletionFailedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingReviews() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return const Right(null);
      }

      final pendingReviews = await _localDataSource.getPendingReviews();
      if (pendingReviews.isEmpty) {
        return const Right(null);
      }

      for (final review in pendingReviews) {
        try {
          if (review.deletedAt != null) {
            await _remoteDataSource.deleteReview(review.id);
            await _localDataSource.deleteLocalRecord(review.id);
          } else if (review.updatedAt != null) {
            await _remoteDataSource.updateReview(review);
            await _localDataSource.markAsSynced(review.id);
          } else {
            final localId = review.id;
            final firebaseId = await _remoteDataSource.createReview(review);
            final syncedReview = review.copyWith(id: firebaseId, isSynced: true);
            await _localDataSource.cacheReview(syncedReview);
            await _localDataSource.deleteLocalRecord(localId);
          }
        } catch (_) {
          
          continue;
        }
      }
      return const Right(null);
    } catch (_) {
      return const Left(ReviewSyncFailedFailure());
    }
  }


  @override
  Future<Either<Failure, ReviewEntity?>> getUserReviewByEntity(
    String userId,
    String entityId,
  ) async {
    try {
      final cachedReview = await _tryGetCachedReview(userId, entityId);

      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return Right(cachedReview?.toEntity());
      }

      try {
        final remoteReview = await _remoteDataSource.getUserReviewByEntity(userId, entityId);

        if (remoteReview != null) {
          await _localDataSource.cacheReview(remoteReview);
          return Right(remoteReview.toEntity());
        }

        if (cachedReview != null && !cachedReview.isSynced) {
          return Right(cachedReview.toEntity());
        }

        return const Right(null);
      } on ServerException {
        if (cachedReview != null) {
          return Right(cachedReview.toEntity());
        }
        return const Left(ReviewFetchFailedFailure());
      }
    } catch (_) {
      return const Left(ReviewNotFoundFailure());
    }
  }

  Future<ReviewModel?> _tryGetCachedReview(String userId, String entityId) async {
    try {
      return await _localDataSource.getUserReviewByEntity(userId, entityId);
    } catch (_) {
      return null;
    }
  }
}
