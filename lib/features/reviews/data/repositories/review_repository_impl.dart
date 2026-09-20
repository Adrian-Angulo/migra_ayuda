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
  Future<void> createReview(ReviewEntity review) async {
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
    } catch (_) {
      throw const ReviewCreationFailedFailure();
    }
  }

  @override
  Future<List<ReviewEntity>> getReviewsByEntity(String entityId) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        try {
          final remoteReviews =
              await remoteDataSource.getReviewsByEntity(entityId);

          await localDataSource.cacheReviews(remoteReviews);
          return remoteReviews.map((r) => r.toEntity()).toList();
        } on ServerException catch (_) {
          // Si falla remoto, intentamos leer de local
        }
      }

      final cachedReviews =
          await localDataSource.getReviewsByEntity(entityId);
      return cachedReviews.map((r) => r.toEntity()).toList();
    } catch (_) {
      throw const ReviewFetchFailedFailure();
    }
  }

  @override
  Future<List<ReviewEntity>> getAllReviews() async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteReviews = await remoteDataSource.getAllReviews();
          await localDataSource.cacheReviews(remoteReviews);
          return remoteReviews.map((r) => r.toEntity()).toList();
        } on ServerException catch (_) {
          // Si falla remoto, intentamos leer de local
        }
      }

      final cachedReviews = await localDataSource.getCachedReviews();
      return cachedReviews.map((r) => r.toEntity()).toList();
    } catch (_) {
      throw const ReviewFetchFailedFailure();
    }
  }

  @override
  Future<void> updateReview(ReviewEntity review) async {
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
          return;
        }
      }
    } catch (_) {
      throw const ReviewUpdateFailedFailure();
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
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
    } catch (_) {
      throw const ReviewDeletionFailedFailure();
    }
  }

  @override
  Future<void> syncPendingReviews() async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return;
      }

      final pendingReviews = await localDataSource.getPendingReviews();
      if (pendingReviews.isEmpty) {
        return;
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
    } catch (_) {
      throw const ReviewSyncFailedFailure();
    }
  }

  @override
  Future<ReviewEntity?> getUserReviewByEntity(
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
            return remoteReview.toEntity();
          }

          if (cachedReview != null && !cachedReview.isSynced) {
            return cachedReview.toEntity();
          }

          return null;
        } on ServerException catch (_) {
          if (cachedReview != null) {
            return cachedReview.toEntity();
          }
          throw const ReviewFetchFailedFailure();
        }
      }

      return cachedReview?.toEntity();
    } catch (_) {
      throw const ReviewNotFoundFailure();
    }
  }
}
