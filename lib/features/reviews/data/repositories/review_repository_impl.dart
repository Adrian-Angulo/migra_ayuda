import 'package:flutter/foundation.dart';
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
      String localId = review.id.isNotEmpty ? review.id : const Uuid().v4();
      ReviewModel reviewModel = ReviewModel.fromReviewEntity(review)
          .copyWith(id: localId, isSynced: kIsWeb);

      if (kIsWeb) {
        await _remoteDataSource.saveReview(reviewModel);
        return const Right(null);
      }

      await _localDataSource
          .createReview(reviewModel.copyWith(isSynced: false));
      _triggerBackgroundSync();
      return const Right(null);
    } catch (_) {
      return const Left(ReviewCreationFailedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByEntity(
      String entityId) async {
    try {
      if (kIsWeb) {
        final remoteReviews =
            await _remoteDataSource.getReviewsByEntity(entityId);
        final reviewEntities = remoteReviews.map((r) => r.toEntity()).toList();
        return Right(reviewEntities);
      }

      final cachedReviews = await _localDataSource.getReviewsByEntity(entityId);
      final reviewEntities =
          cachedReviews.map((reviewModel) => reviewModel.toEntity()).toList();
      return Right(reviewEntities);
    } catch (error) {
      return const Left(ReviewFetchFailedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getAllReviews() async {
    try {
      List<ReviewModel> reviews;

      reviews = await _remoteDataSource.getAllReviews();

      final reviewEntities = reviews.map((r) => r.toEntity()).toList();
      return Right(reviewEntities);
    } catch (_) {
      return const Left(ReviewFetchFailedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateReview(ReviewEntity review) async {
    try {
      if (kIsWeb) {
        final model = ReviewModel.fromReviewEntity(review, isSynced: true)
            .copyWith(updatedAt: DateTime.now());
        await _remoteDataSource.saveReview(model);
        return const Right(null);
      }

      final updatedModel = ReviewModel.fromReviewEntity(
        review,
        isSynced: false,
      ).copyWith(updatedAt: DateTime.now());

      await _localDataSource.updateReview(updatedModel);
      _triggerBackgroundSync();
      return const Right(null);
    } catch (_) {
      return const Left(ReviewUpdateFailedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      if (kIsWeb) {
        await _remoteDataSource.deleteReview(reviewId);
        return const Right(null);
      }

      final review = await _localDataSource.getReviewById(reviewId);

      final updatedReview = review.copyWith(
        isSynced: false,
        deletedAt: DateTime.now(),
      );

      await _localDataSource.updateReview(updatedReview);
      _triggerBackgroundSync();
      return const Right(null);
    } catch (_) {
      return const Left(ReviewDeletionFailedFailure());
    }
  }

  void _triggerBackgroundSync() {
    if (kIsWeb) return;
    syncPendingReviews().catchError((_) {
      return const Left(ReviewSyncFailedFailure());
    });
  }

  @override
  Future<Either<Failure, void>> syncPendingReviews() async {
    if (kIsWeb) {
      return const Right(null);
    }
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
          } else {
            await _remoteDataSource.saveReview(review);
            await _localDataSource.markAsSynced(review.id);
          }
        } catch (e) {
          continue;
        }
      }

      return const Right(null);
    } catch (e) {
      return const Left(ReviewSyncFailedFailure());
    }
  }
}
