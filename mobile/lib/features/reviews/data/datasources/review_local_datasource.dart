import 'package:sembast/sembast.dart';
import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:migra_ayuda/features/reviews/data/models/review_model.dart';

/// Excepción personalizada para errores de caché
class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Interfaz abstracta para el datasource local de reviews
abstract class ReviewLocalDataSource {
  /// Obtiene todas las reviews del caché
  Future<List<ReviewModel>> getCachedReviews();

  /// Obtiene las reviews de una entidad específica del caché
  Future<List<ReviewModel>> getReviewsByEntity(String entityId);

  /// Guarda una review individual en el caché
  Future<void> cacheReview(ReviewModel review);

  /// Guarda múltiples reviews en el caché
  Future<void> cacheReviews(List<ReviewModel> reviews);

  /// Elimina una review del caché (soft delete - marca deletedAt)
  Future<void> deleteReview(String reviewId);

  /// Obtiene las reviews pendientes de sincronización (isSynced = false)
  Future<List<ReviewModel>> getPendingReviews();

  /// Marca una review como sincronizada
  Future<void> markAsSynced(String reviewId);

  /// Limpia todo el caché de reviews
  Future<void> clearCache();

  /// Obtiene la review de un usuario específico en una entidad
  Future<ReviewModel?> getUserReviewByEntity(String userId, String entityId);

  /// Elimina un registro local por ID (hard delete - para limpiar duplicados)
  Future<void> deleteLocalRecord(String recordId);
}

/// Implementación del datasource local usando Sembast
class ReviewLocalDataSourceImpl implements ReviewLocalDataSource {
  final SembastDatabase sembastDatabase;

  // Store para las reviews
  final _store = stringMapStoreFactory.store('reviews');

  ReviewLocalDataSourceImpl({required this.sembastDatabase});

  /// Obtiene la instancia de la base de datos
  Future<Database> get _db async => await sembastDatabase.database;

  @override
  Future<List<ReviewModel>> getCachedReviews() async {
    try {
      final db = await _db;

      // Obtiene todos los registros no eliminados, ordenados por fecha de creación (más recientes primero)
      final finder = Finder(
        filter: Filter.isNull('deletedAt'), // Excluye reviews eliminadas
        sortOrders: [SortOrder('createdAt', false)], // false = descendente
      );
      final records = await _store.find(db, finder: finder);

      // Convierte los registros a ReviewModel
      return records.map((record) {
        return _fromSembastMap(record.key, record.value);
      }).toList();
    } catch (e) {
      throw CacheException('Error al obtener reviews del caché: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsByEntity(String entityId) async {
    try {
      final db = await _db;

      // Filtra por entityId, excluye eliminadas y ordena por fecha
      final finder = Finder(
        filter: Filter.and([
          Filter.equals('idEntity', entityId),
          Filter.isNull('deletedAt'), // Excluye reviews eliminadas
        ]),
        sortOrders: [SortOrder('createdAt', false)],
      );
      final records = await _store.find(db, finder: finder);

      // Convierte los registros a ReviewModel
      return records.map((record) {
        return _fromSembastMap(record.key, record.value);
      }).toList();
    } catch (e) {
      throw CacheException(
          'Error al obtener reviews de la entidad del caché: $e');
    }
  }

  @override
  Future<void> cacheReview(ReviewModel review) async {
    try {
      final db = await _db;

      // Guarda o actualiza la review
      await _store.record(review.id).put(db, _toSembastMap(review));
    } catch (e) {
      throw CacheException('Error al guardar review en caché: $e');
    }
  }

  @override
  Future<void> cacheReviews(List<ReviewModel> reviews) async {
    try {
      final db = await _db;

      // Guarda todas las reviews (no limpia el store, solo actualiza/agrega)
      for (final review in reviews) {
        await _store.record(review.id).put(db, _toSembastMap(review));
      }
    } catch (e) {
      throw CacheException('Error al guardar reviews en caché: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      final db = await _db;

      // Obtiene la review actual
      final record = await _store.record(reviewId).get(db);

      if (record == null) {
        throw CacheException('Review no encontrada en caché');
      }

      // Marca como eliminada (soft delete)
      final updatedRecord = Map<String, dynamic>.from(record);
      updatedRecord['deletedAt'] = DateTime.now().millisecondsSinceEpoch;
      updatedRecord['isSynced'] = false; // Marca como no sincronizada

      // Actualiza el registro
      await _store.record(reviewId).put(db, updatedRecord);
    } catch (e) {
      throw CacheException('Error al eliminar review del caché: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getPendingReviews() async {
    try {
      final db = await _db;

      // Filtra por isSynced = false
      final finder = Finder(
        filter: Filter.equals('isSynced', false),
        sortOrders: [SortOrder('createdAt', false)],
      );
      final records = await _store.find(db, finder: finder);

      // Convierte los registros a ReviewModel
      return records.map((record) {
        return _fromSembastMap(record.key, record.value);
      }).toList();
    } catch (e) {
      throw CacheException('Error al obtener reviews pendientes: $e');
    }
  }

  @override
  Future<void> markAsSynced(String reviewId) async {
    try {
      final db = await _db;

      // Obtiene la review actual
      final record = await _store.record(reviewId).get(db);

      if (record == null) {
        throw CacheException('Review no encontrada en caché');
      }

      // Marca como sincronizada
      final updatedRecord = Map<String, dynamic>.from(record);
      updatedRecord['isSynced'] = true;

      // Actualiza el registro
      await _store.record(reviewId).put(db, updatedRecord);
    } catch (e) {
      throw CacheException('Error al marcar review como sincronizada: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final db = await _db;

      // Limpia todo el store
      await _store.delete(db);
    } catch (e) {
      throw CacheException('Error al limpiar caché de reviews: $e');
    }
  }

  @override
  Future<ReviewModel?> getUserReviewByEntity(
      String userId, String entityId) async {
    try {
      final db = await _db;

      // Filtra por userId (idMigrante) y entityId, excluyendo eliminadas
      final finder = Finder(
        filter: Filter.and([
          Filter.equals('idMigrante', userId),
          Filter.equals('idEntity', entityId),
          Filter.isNull('deletedAt'), // Excluye reviews eliminadas
        ]),
        sortOrders: [SortOrder('createdAt', false)],
        limit: 1, // Solo necesitamos una
      );

      final records = await _store.find(db, finder: finder);

      // Si no hay registros, retorna null
      if (records.isEmpty) {
        return null;
      }

      // Convierte el primer registro a ReviewModel
      return _fromSembastMap(records.first.key, records.first.value);
    } catch (e) {
      throw CacheException('Error al obtener review del usuario en caché: $e');
    }
  }

  @override
  Future<void> deleteLocalRecord(String recordId) async {
    try {
      final db = await _db;

      // Elimina el registro físicamente (hard delete)
      await _store.record(recordId).delete(db);
    } catch (e) {
      throw CacheException('Error al eliminar registro local: $e');
    }
  }

  /// Convierte ReviewModel a Map para Sembast
  Map<String, dynamic> _toSembastMap(ReviewModel review) {
    return {
      'idMigrante': review.idMigrante,
      'idEntity': review.idEntity,
      'userName': review.userName,
      'userCountry': review.userCountry,
      'rating': review.rating,
      'comment': review.comment,
      'createdAt': review.createdAt.millisecondsSinceEpoch,
      'updatedAt': review.updatedAt?.millisecondsSinceEpoch,
      'deletedAt': review.deletedAt?.millisecondsSinceEpoch,
      'isSynced': review.isSynced,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Convierte Map de Sembast a ReviewModel
  ReviewModel _fromSembastMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      idMigrante: map['idMigrante'] ?? '',
      idEntity: map['idEntity'] ?? '',
      userName: map['userName'] ?? '',
      userCountry: map['userCountry'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      deletedAt: map['deletedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deletedAt'])
          : null,
      isSynced: map['isSynced'] ?? false,
    );
  }
}
