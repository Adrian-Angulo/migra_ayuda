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

      final isConnected = await _networkInfo.isConnected;
      if (isConnected) {
        final firebaseId = await _remoteDataSource.createReview(reviewModel);
        final syncedReview = reviewModel.copyWith(id: firebaseId, isSynced: true);
        await _localDataSource.cacheReview(syncedReview);
        await _localDataSource.deleteLocalRecord(localId);
      }

      return const Right(null);
    } catch (_) {
      return const Left(ReviewCreationFailedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByEntity(String entityId) async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteReviews = await _remoteDataSource.getReviewsByEntity(entityId);
          await _localDataSource.cacheReviews(remoteReviews);
          return Right(remoteReviews.map((r) => r.toEntity()).toList());
        } on ServerException catch (_) {
          
        }
      }

      final cachedReviews = await _localDataSource.getReviewsByEntity(entityId);
      return Right(cachedReviews.map((r) => r.toEntity()).toList());
    } catch (_) {
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
          // Fallback to local cache on server failure
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

      final isConnected = await _networkInfo.isConnected;
      if (isConnected) {
        try {
          await _remoteDataSource.updateReview(updatedModel);
          await _localDataSource.markAsSynced(review.id);
        } catch (_) {
          return const Right(null); // If remote update fails, consider as success (sync pending)
        }
      }
      return const Right(null);
    } catch (_) {
      return const Left(ReviewUpdateFailedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      await _localDataSource.deleteReview(reviewId);

      final isConnected = await _networkInfo.isConnected;
      if (isConnected) {
        try {
          await _remoteDataSource.deleteReview(reviewId);
          await _localDataSource.deleteLocalRecord(reviewId);
        } catch (_) {
          // Fallback: Review deleted locally, sync pending for remote
        }
      }
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
          // Continue syncing next review on error
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
      ReviewModel? cachedReview;
      try {
        cachedReview = await _localDataSource.getUserReviewByEntity(userId, entityId);
      } catch (_) {
        cachedReview = null;
      }

      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
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
      }

      return Right(cachedReview?.toEntity());
    } catch (_) {
      return const Left(ReviewNotFoundFailure());
    }
  }
}
