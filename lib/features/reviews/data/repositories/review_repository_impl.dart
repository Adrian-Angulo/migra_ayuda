import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
  final ReviewRemoteDataSource remoteDataSource;
  final ReviewLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ReviewRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> createReview(ReviewEntity review) async {
    try {
      final localId = const Uuid().v4();
      final reviewModel = ReviewModel.fromReviewEntity(review);
      final modelo = reviewModel.copyWith(id: localId);

      await localDataSource.cacheReview(modelo);

      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        final firebaseId = await remoteDataSource.createReview(modelo);
        final reviewUpdate = modelo.copyWith(id: firebaseId, isSynced: true);
        await localDataSource.cacheReview(reviewUpdate);
        await localDataSource.deleteLocalRecord(localId);
      }
      return const Right(null);
    } catch (_) {
      return const Left(ReviewCreationFailedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByEntity(
    String entityId,
  ) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        try {
          final remoteReviews =
              await remoteDataSource.getReviewsByEntity(entityId);

          await localDataSource.cacheReviews(remoteReviews);
          return Right(remoteReviews.map((r) => r.toEntity()).toList());
        } on ServerException catch (_) {
          // Si falla remoto, intentamos leer de local
        }
      }

      final cachedReviews =
          await localDataSource.getReviewsByEntity(entityId);
      return Right(cachedReviews.map((r) => r.toEntity()).toList());
    } catch (_) {
      return const Left(ReviewFetchFailedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getAllReviews() async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteReviews = await remoteDataSource.getAllReviews();
          await localDataSource.cacheReviews(remoteReviews);
          return Right(remoteReviews.map((r) => r.toEntity()).toList());
        } on ServerException catch (_) {
          // Si falla remoto, intentamos leer de local
        }
      }

      final cachedReviews = await localDataSource.getCachedReviews();
      return Right(cachedReviews.map((r) => r.toEntity()).toList());
    } catch (_) {
      return const Left(ReviewFetchFailedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateReview(ReviewEntity review) async {
    try {
      final modelo = ReviewModel.fromReviewEntity(
        review,
        isSynced: false,
      ).copyWith(
        updatedAt: DateTime.now(),
      );
      await localDataSource.cacheReview(modelo);

      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        try {
          await remoteDataSource.updateReview(modelo);
          await localDataSource.markAsSynced(review.id);
        } catch (_) {
          return const Right(null);
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
      await localDataSource.deleteReview(reviewId);

      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        try {
          await remoteDataSource.deleteReview(reviewId);
          await localDataSource.deleteLocalRecord(reviewId);
        } catch (_) {
          // Si falla en remoto, queda eliminado localmente
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
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Right(null);
      }

      final pendingReviews = await localDataSource.getPendingReviews();
      if (pendingReviews.isEmpty) {
        return const Right(null);
      }

      for (final review in pendingReviews) {
        try {
          if (review.deletedAt != null) {
            await remoteDataSource.deleteReview(review.id);
            await localDataSource.deleteLocalRecord(review.id);
          } else if (review.updatedAt != null) {
            await remoteDataSource.updateReview(review);
            await localDataSource.markAsSynced(review.id);
          } else {
            final localId = review.id;
            final firebaseId = await remoteDataSource.createReview(review);

            final modelo = review.copyWith(id: firebaseId, isSynced: true);

            await localDataSource.cacheReview(modelo);
            await localDataSource.deleteLocalRecord(localId);
            continue;
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
      ReviewModel? cachedReview;

      try {
        cachedReview =
            await localDataSource.getUserReviewByEntity(userId, entityId);
      } catch (_) {
        cachedReview = null;
      }

      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteReview =
              await remoteDataSource.getUserReviewByEntity(userId, entityId);

          if (remoteReview != null) {
            await localDataSource.cacheReview(remoteReview);
            return Right(remoteReview.toEntity());
          }

          if (cachedReview != null && !cachedReview.isSynced) {
            return Right(cachedReview.toEntity());
          }

          return const Right(null);
        } on ServerException catch (_) {
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
