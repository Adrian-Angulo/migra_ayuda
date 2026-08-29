import 'package:flutter/foundation.dart';
import 'package:migra_ayuda/core/network/network_info.dart';
import 'package:migra_ayuda/features/reviews/data/datasources/review_local_datasource.dart';
import 'package:migra_ayuda/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:migra_ayuda/features/reviews/data/models/review_model.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementación del repositorio de reviews con estrategia Offline-First
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
    } catch (e) {
      throw Exception('Error al crear la review: ${e.toString()}');
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
        } on ServerException catch (e) {
          debugPrint('⚠️ Error del servidor al obtener reviews: ${e.message}');
        }
      }

      final cachedReviews =
          await localDataSource.getReviewsByEntity(entityId);
      return cachedReviews.map((r) => r.toEntity()).toList();
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener las reviews: ${e.toString()}');
    }
  }

  @override
  Future<List<ReviewEntity>> getAllReviews() async {
    try {
      // Verificamos si hay conexión a internet
      final isConnected = await networkInfo.isConnected;

      // Si hay internet, intentamos sincronizar las reviews más recientes del servidor
      if (isConnected) {
        try {
          final remoteReviews = await remoteDataSource.getAllReviews();
          await localDataSource.cacheReviews(remoteReviews);
          return remoteReviews.map((r) => r.toEntity()).toList();
        } on ServerException catch (e) {
          debugPrint('⚠️ Error del servidor al obtener reviews: ${e.message}');
        }
      }

      // Retornamos las reviews de caché local (excluye las marcadas como eliminadas)
      final cachedReviews = await localDataSource.getCachedReviews();
      return cachedReviews.map((r) => r.toEntity()).toList();
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener las reviews: ${e.toString()}');
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
        } catch (e) {
          return;
        }
      }
    } catch (e) {
      throw Exception('Error al actualizar la review: ${e.toString()}');
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
        } catch (e) {
          debugPrint('⚠️ Error al eliminar en Firebase: $e');
        }
      }
    } catch (e) {
      throw Exception('Error al eliminar la review: ${e.toString()}');
    }
  }

  @override
  Future<void> syncPendingReviews() async {
    try {
      debugPrint('incio sincronizacion de review');
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        debugPrint('⚠️ No hay conexión a internet para sincronizar reviews');
        return;
      }

      final pendingReviews = await localDataSource.getPendingReviews();
      if (pendingReviews.isEmpty) {
        debugPrint('No hay reviews pedientes');
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
        } catch (e) {
          debugPrint('⚠️ Error al sincronizar review ${review.id}: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error al sincronizar reviews: ${e.toString()}');
      throw Exception('Error al sincronizar las reviews');
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
      } catch (e) {
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
        } on ServerException catch (e) {
          if (cachedReview != null) {
            return cachedReview.toEntity();
          }
          throw Exception('Error del servidor: ${e.message}');
        }
      }

      return cachedReview?.toEntity();
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
          'Error al obtener la review del usuario: ${e.toString()}');
    }
  }
}
