import 'package:dartz/dartz.dart';
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
  Future<Either<String, Unit>> createReview(ReviewEntity review) async {
    try {
      // Genera un ID único local
      final localId = const Uuid().v4();

      // Crea el modelo con el ID local
      final modelo = ReviewModel(
        id: localId,
        idMigrante: review.idMigrante,
        idEntity: review.idEntity,
        userName: review.userName,
        userCountry: review.userCountry,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
        updatedAt: review.updatedAt,
        deletedAt: review.deletedAt,
        isSynced: false, // Inicialmente no sincronizada
      );

      // 1. Guarda primero en caché local (respuesta inmediata)
      await localDataSource.cacheReview(modelo);

      // 2. Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // 3. Si hay internet, sube a Firebase
          final firebaseId = await remoteDataSource.createReview(modelo);

          // 4. Crea el modelo con el ID de Firebase
          final syncedModel = ReviewModel(
            id: firebaseId, // Usa el ID de Firebase
            idMigrante: modelo.idMigrante,
            idEntity: modelo.idEntity,
            userName: modelo.userName,
            userCountry: modelo.userCountry,
            rating: modelo.rating,
            comment: modelo.comment,
            createdAt: modelo.createdAt,
            updatedAt: modelo.updatedAt,
            deletedAt: modelo.deletedAt,
            isSynced: true, // Marca como sincronizada
          );

          // 5. PRIMERO guarda con el ID de Firebase
          await localDataSource.cacheReview(syncedModel);

          // 6. DESPUÉS elimina el registro con ID local para evitar duplicados
          await localDataSource.deleteLocalRecord(localId);
        } catch (e) {
          // Si falla Firebase, los datos ya están en caché local
          return right(unit); // Éxito parcial (guardado localmente)
        }
      }
      // Si no hay internet, queda pendiente de sincronización

      return right(unit);
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al crear la review: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<ReviewEntity>>> getReviewsByEntity(
      String entityId) async {
    try {
      // ESTRATEGIA CACHE-FIRST:
      // 1. Primero intenta obtener del caché (respuesta inmediata)
      List<ReviewModel> cachedReviews = [];

      try {
        cachedReviews = await localDataSource.getReviewsByEntity(entityId);
      } catch (e) {
        // Si falla el caché, continúa con lista vacía
        cachedReviews = [];
      }

      // 2. Verifica si hay conexión para actualizar en background
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // Obtiene datos frescos de Firebase
          final remoteReviews =
              await remoteDataSource.getReviewsByEntity(entityId);

          // Actualiza el caché con los datos frescos
          await localDataSource.cacheReviews(remoteReviews);

          // Retorna los datos frescos de Firebase
          return right(remoteReviews);
        } on ServerException catch (e) {
          // Si falla Firebase pero hay caché, retorna el caché
          if (cachedReviews.isNotEmpty) {
            return right(cachedReviews);
          }
          return left('Error del servidor: ${e.message}');
        }
      }

      // 3. Sin internet, retorna el caché
      if (cachedReviews.isNotEmpty) {
        return right(cachedReviews);
      }

      // 4. Sin caché y sin internet
      return left('No hay datos disponibles. Verifica tu conexión a internet.');
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al obtener las reviews: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<ReviewEntity>>> getAllReviews() async {
    try {
      // ESTRATEGIA CACHE-FIRST:
      // 1. Primero intenta obtener del caché (respuesta inmediata)
      List<ReviewModel> cachedReviews = [];

      try {
        cachedReviews = await localDataSource.getCachedReviews();
      } catch (e) {
        // Si falla el caché, continúa con lista vacía
        cachedReviews = [];
      }

      // 2. Verifica si hay conexión para actualizar en background
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // Obtiene datos frescos de Firebase
          final remoteReviews = await remoteDataSource.getAllReviews();

          // Actualiza el caché con los datos frescos
          await localDataSource.cacheReviews(remoteReviews);

          // Retorna los datos frescos de Firebase
          return right(remoteReviews);
        } on ServerException catch (e) {
          // Si falla Firebase pero hay caché, retorna el caché
          if (cachedReviews.isNotEmpty) {
            return right(cachedReviews);
          }
          return left('Error del servidor: ${e.message}');
        }
      }

      // 3. Sin internet, retorna el caché
      if (cachedReviews.isNotEmpty) {
        return right(cachedReviews);
      }

      // 4. Sin caché y sin internet
      return left('No hay datos disponibles. Verifica tu conexión a internet.');
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al obtener las reviews: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> updateReview(ReviewEntity review) async {
    try {
      final modelo = ReviewModel(
        id: review.id,
        idMigrante: review.idMigrante,
        idEntity: review.idEntity,
        userName: review.userName,
        userCountry: review.userCountry,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
        updatedAt: DateTime.now(), // Actualiza timestamp
        deletedAt: review.deletedAt,
        isSynced: false, // Marca como no sincronizada
      );

      // 1. Primero actualiza en caché local (respuesta inmediata)
      await localDataSource.cacheReview(modelo);

      // 2. Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // 3. Si hay internet, sincroniza con Firebase
          await remoteDataSource.updateReview(modelo);

          // 4. Marca como sincronizada en caché
          await localDataSource.markAsSynced(review.id);
        } catch (e) {
          // Si falla Firebase, los datos ya están en caché
          return right(unit); // Éxito parcial (actualizado localmente)
        }
      }
      // Si no hay internet, queda pendiente de sincronización

      return right(unit);
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al actualizar la review: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> deleteReview(String reviewId) async {
    try {
      // 1. Primero marca como eliminada en caché local (soft delete)
      await localDataSource.deleteReview(reviewId);

      // 2. Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // 3. Si hay internet, elimina de Firebase (hard delete)
          await remoteDataSource.deleteReview(reviewId);
        } catch (e) {
          // Si falla Firebase, ya está marcada como eliminada localmente
          return right(unit); // Éxito parcial (eliminada localmente)
        }
      }
      // Si no hay internet, queda pendiente de sincronización

      return right(unit);
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al eliminar la review: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> syncPendingReviews() async {
    try {
      // 1. Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return left('No hay conexión a internet para sincronizar');
      }

      // 2. Obtiene las reviews pendientes de sincronización
      final pendingReviews = await localDataSource.getPendingReviews();

      if (pendingReviews.isEmpty) {
        return right(unit); // No hay nada que sincronizar
      }

      // 3. Sincroniza cada review pendiente
      for (final review in pendingReviews) {
        try {
          if (review.deletedAt != null) {
            // Si está marcada como eliminada, elimina de Firebase
            await remoteDataSource.deleteReview(review.id);
          } else if (review.updatedAt != null) {
            // Si tiene updatedAt, es una actualización
            await remoteDataSource.updateReview(review);
          } else {
            // Si no tiene updatedAt, es una creación
            final localId = review.id; // Guarda el ID local
            final firebaseId = await remoteDataSource.createReview(review);

            // Crea el modelo con el ID de Firebase
            final syncedModel = ReviewModel(
              id: firebaseId,
              idMigrante: review.idMigrante,
              idEntity: review.idEntity,
              userName: review.userName,
              userCountry: review.userCountry,
              rating: review.rating,
              comment: review.comment,
              createdAt: review.createdAt,
              updatedAt: review.updatedAt,
              deletedAt: review.deletedAt,
              isSynced: true,
            );

            // PRIMERO guarda con el ID de Firebase
            await localDataSource.cacheReview(syncedModel);

            // DESPUÉS elimina el registro con ID local para evitar duplicados
            await localDataSource.deleteLocalRecord(localId);

            continue; // Ya está sincronizada, continúa con la siguiente
          }

          // Marca como sincronizada
          await localDataSource.markAsSynced(review.id);
        } catch (e) {
          // Si falla una review, continúa con las demás
          print('⚠️ Error al sincronizar review ${review.id}: $e');
          continue;
        }
      }

      return right(unit);
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al sincronizar reviews: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ReviewEntity?>> getUserReviewByEntity(
    String userId,
    String entityId,
  ) async {
    try {
      // ESTRATEGIA CACHE-FIRST:
      // 1. Primero intenta obtener del caché (respuesta inmediata)
      ReviewModel? cachedReview;

      try {
        cachedReview =
            await localDataSource.getUserReviewByEntity(userId, entityId);
      } catch (e) {
        // Si falla el caché, continúa con null
        cachedReview = null;
      }

      // 2. Verifica si hay conexión para actualizar en background
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // Obtiene datos frescos de Firebase
          final remoteReview =
              await remoteDataSource.getUserReviewByEntity(userId, entityId);

          // Si hay review remota, actualiza el caché
          if (remoteReview != null) {
            await localDataSource.cacheReview(remoteReview);
          }

          // Retorna los datos frescos de Firebase
          return right(remoteReview);
        } on ServerException catch (e) {
          // Si falla Firebase pero hay caché, retorna el caché
          if (cachedReview != null) {
            return right(cachedReview);
          }
          return left('Error del servidor: ${e.message}');
        }
      }

      // 3. Sin internet, retorna el caché (puede ser null)
      return right(cachedReview);
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al obtener la review del usuario: ${e.toString()}');
    }
  }
}
