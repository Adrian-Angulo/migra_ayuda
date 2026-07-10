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

      // Usa el localId para crear el modelo inicial
      final modelo = ReviewModel.fromReviewEntity(review, id: localId);

      // 1. Guarda primero en caché local (respuesta inmediata)
      await localDataSource.cacheReview(modelo);

      // 2. Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final firebaseId = await remoteDataSource.createReview(modelo);
          final reviewUpdate = modelo.copyWith(id: firebaseId, isSynced: true);
          await localDataSource.cacheReview(reviewUpdate);
          await remoteDataSource.updateReview(reviewUpdate);
          await localDataSource.deleteLocalRecord(localId);
        } catch (e) {
          return right(unit);
        }
      }
      return right(unit);
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
      cachedReviews = await localDataSource.getReviewsByEntity(entityId);

      // 2. Verifica si hay conexión para actualizar
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        try {
          // Obtiene datos frescos de Firebase
          final remoteReviews =
              await remoteDataSource.getReviewsByEntity(entityId);

          // Actualiza el caché con los datos actualizados
          await localDataSource.cacheReviews(remoteReviews);
          // Retorna los datos actualizado de Firebase
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
    } catch (e) {
      return left('Error al obtener las reviews: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> updateReview(ReviewEntity review) async {
    try {
      final modelo = ReviewModel.fromReviewEntity(
        review,
        isSynced: false, // Marca como no sincronizada
      ).copyWith(
        updatedAt: DateTime.now(), // Actualiza timestamp
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
    } catch (e) {
      return left('Error al actualizar la review: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> deleteReview(String reviewId) async {
    try {
      await localDataSource.deleteReview(reviewId);

      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        try {
          await remoteDataSource.deleteReview(reviewId);
        } catch (e) {
          return right(unit);
        }
      }
      return right(unit);
    } catch (e) {
      return left('Error al eliminar la review: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> syncPendingReviews() async {
    try {
      // 1. Verifica si hay conexión a internet antes de intentar sincronizar
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return left('No hay conexión a internet para sincronizar');
      }
      // 2. Obtiene todas las reviews locales pendientes de sincronización (isSynced: false)
      final pendingReviews = await localDataSource.getPendingReviews();
      // Si no hay reviews pendientes, no hay nada que sincronizar
      if (pendingReviews.isEmpty) {
        return right(unit);
      }
      // 3. Sincroniza cada review pendiente con Firebase
      for (final review in pendingReviews) {
        try {
          if (review.deletedAt != null) {
            // Caso A: La review fue eliminada localmente → elimina también en Firebase
            await remoteDataSource.deleteReview(review.id);
          } else if (review.updatedAt != null) {
            // Caso B: La review fue modificada localmente → actualiza en Firebase
            await remoteDataSource.updateReview(review);
          } else {
            // Caso C: La review fue creada localmente → crea en Firebase y reemplaza el ID local
            final localId =
                review.id; // Guarda el ID temporal generado localmente

            // Crea la review en Firebase y obtiene el ID definitivo generado por Firestore
            final firebaseId = await remoteDataSource.createReview(review);

            // Construye un nuevo modelo con el ID de Firebase y marcada como sincronizada
            final modelo = ReviewModel.fromReviewEntity(review,
                id: firebaseId, isSynced: true);

            // Guarda el modelo actualizado con el ID de Firebase en el caché local
            await localDataSource.cacheReview(modelo);

            // Elimina el registro temporal que usaba el ID local
            await localDataSource.deleteLocalRecord(localId);

            // Salta al siguiente ítem, ya que este fue manejado completamente
            continue;
          }

          // Marca la review como sincronizada en el caché local (aplica a casos A y B)
          await localDataSource.markAsSynced(review.id);
        } catch (e) {
          // Si falla una review individual, registra el error y continúa con las demás
          // Esto evita que un fallo puntual detenga toda la sincronización
          print('⚠️ Error al sincronizar review ${review.id}: $e');
          continue;
        }
      }
      return right(unit);
    } catch (e) {
      // Error general inesperado durante el proceso de sincronización
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
      // 1. Retorna inmediatamente desde el caché local
      ReviewModel? cachedReview;

      try {
        cachedReview =
            await localDataSource.getUserReviewByEntity(userId, entityId);
      } catch (e) {
        cachedReview = null;
      }

      // 2. Verifica conexión para actualizar el caché en segundo plano
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // Obtiene datos frescos de Firebase
          final remoteReview =
              await remoteDataSource.getUserReviewByEntity(userId, entityId);

          // Actualiza el caché con los datos remotos más recientes
          if (remoteReview != null) {
            await localDataSource.cacheReview(remoteReview);
            // Retorna los datos frescos de Firebase
            return right(remoteReview);
          }

          // Si no hay review remota pero sí local, la review fue eliminada remotamente
          // Respeta la fuente de verdad remota y retorna null
          return right(null);
        } on ServerException catch (e) {
          // Si falla Firebase pero hay caché, retorna el caché como fallback
          if (cachedReview != null) {
            return right(cachedReview);
          }
          return left('Error del servidor: ${e.message}');
        }
      }
      // 3. Sin internet, retorna el caché como respuesta (puede ser null)
      return right(cachedReview);
    } catch (e) {
      return left('Error al obtener la review del usuario: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> syncAllFromFirebase() async {
    try {
      // 1. Verificar conexión a internet
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return left('Sin conexión a internet para sincronizar');
      }

      // 2. Descargar TODAS las reviews de Firebase
      final remoteReviews = await remoteDataSource.getAllReviews();

      // 3. Obtener reviews locales pendientes de sincronización (isSynced: false)
      final pendingLocal = await localDataSource.getPendingReviews();

      // 4. Merge inteligente: combina Firebase + pendientes locales
      final merged = _mergeReviews(remoteReviews, pendingLocal);

      // 5. Limpiar caché y guardar todo
      await localDataSource.clearCache();
      await localDataSource.cacheReviews(merged);

      return right(unit);
    } catch (e) {
      return left(
          'Error al sincronizar reviews desde Firebase: ${e.toString()}');
    }
  }

  /// Método auxiliar para merge inteligente de reviews
  ///
  /// Combina reviews remotas con reviews locales pendientes.
  /// Las reviews locales pendientes tienen prioridad (no se sobrescriben).
  List<ReviewModel> _mergeReviews(
    List<ReviewModel> remote,
    List<ReviewModel> pending,
  ) {
    final Map<String, ReviewModel> merged = {};

    // Primero agrega todas las reviews remotas
    for (final review in remote) {
      merged[review.id] = review;
    }

    // Luego sobrescribe con reviews locales pendientes (tienen prioridad)
    // Esto evita perder cambios locales no sincronizados
    for (final review in pending) {
      merged[review.id] = review;
    }
    return merged.values.toList();
  }
}
