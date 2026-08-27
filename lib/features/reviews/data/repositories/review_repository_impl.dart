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
      List<ReviewModel> cachedReviews = [];
      try {
        cachedReviews = await localDataSource.getReviewsByEntity(entityId);
      } catch (e) {
        cachedReviews = [];
      }

      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        try {
          final remoteReviews =
              await remoteDataSource.getReviewsByEntity(entityId);

          await localDataSource.cacheReviews(remoteReviews);
          return remoteReviews.map((r) => r.toEntity()).toList();
        } on ServerException catch (e) {
          if (cachedReviews.isNotEmpty) {
            return cachedReviews.map((r) => r.toEntity()).toList();
          }
          throw Exception('Error del servidor: ${e.message}');
        }
      }

      return cachedReviews.map((r) => r.toEntity()).toList();
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener las reviews: ${e.toString()}');
    }
  }

  @override
  Future<List<ReviewEntity>> getAllReviews() async {
    try {
      // Lista para almacenar reviews en caché local
      List<ReviewModel> cachedReviews = [];

      // Intentamos cargar las reviews en caché local
      try {
        cachedReviews = await localDataSource.getCachedReviews();
      } catch (e) {
        // Si hay algún error al obtener la caché, continuamos con lista vacía
        cachedReviews = [];
      }

      // Verificamos si hay conexión a internet
      final isConnected = await networkInfo.isConnected;

      // Si hay internet, intentamos obtener las reviews más recientes del servidor
      if (isConnected) {
        try {
          // Obtenemos las reviews desde el origen remoto (ej: Firebase)
          final remoteReviews = await remoteDataSource.getAllReviews();

          // Guardamos/cachéamos las reviews obtenidas remotamente en el almacenamiento local
          await localDataSource.cacheReviews(remoteReviews);

          // Convertimos y devolvemos la lista de modelos a entidades de dominio
          return remoteReviews.map((r) => r.toEntity()).toList();
        } on ServerException catch (e) {
          // En caso de error del servidor y si hay reviews en caché, devolvemos la caché
          if (cachedReviews.isNotEmpty) {
            return cachedReviews.map((r) => r.toEntity()).toList();
          }
          // Si no hay reviews en caché, lanzamos excepción específica de servidor
          throw Exception('Error del servidor: ${e.message}');
        }
      }

      // Si no hay internet, devolvemos los datos en caché local (incluso si está vacía)
      return cachedReviews.map((r) => r.toEntity()).toList();
    } catch (e) {
      // Si la excepción ya es del tipo Exception, volvemos a lanzarla
      if (e is Exception) rethrow;
      // Cualquier otro error inesperado se encapsula en una Exception custom
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
          return;
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
