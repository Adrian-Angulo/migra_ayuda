import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/features/reviews/data/models/review_model.dart';


class ReviewLocalDataSource {
  final SembastDatabase sembastDatabase;

  // Store para las reviews
  final _store = stringMapStoreFactory.store('reviews');
  ReviewLocalDataSource({required this.sembastDatabase});

  /// Obtiene la instancia de la base de datos
  Future<Database> get _db async => await sembastDatabase.database;

  Future<List<ReviewModel>> getCachedReviews() async {
    // En web no se usa caché local
    if (kIsWeb) return [];
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
        return ReviewModel.fromSembastMap(record.key, record.value);
      }).toList();
    } catch (e) {
      throw 'Error al obtener reviews del caché: $e';
    }
  }

  Future<List<ReviewModel>> getReviewsByEntity(String entityId) async {
    // En web no se usa caché local
    if (kIsWeb) return [];

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
        return ReviewModel.fromSembastMap(record.key, record.value);
      }).toList();
    } catch (e) {
      print('❌ Error en getReviewsByEntity: $e');
      throw 'Error al obtener reviews de la entidad del caché: $e';
    }
  }

  Future<void> cacheReview(ReviewModel review) async {
    // En web no se usa caché local
    if (kIsWeb) return;

    try {
      final db = await _db;

      // Guarda o actualiza la review
      await _store.record(review.id).put(db, review.toMap());
    } catch (e) {
      throw 'Error al guardar review en caché: $e';
    }
  }

  Future<void> cacheReviews(List<ReviewModel> reviews) async {
    // En web no se usa caché local
    if (kIsWeb) return;

    try {
      final db = await _db;

      // Guarda todas las reviews usando _toSembastMap para consistencia
      for (final review in reviews) {
        await _store.record(review.id).put(db, review.toMap());
      }
    } catch (e) {
      throw 'Error al guardar reviews en caché: $e';
    }
  }

  Future<void> deleteReview(String reviewId) async {
    // En web no se usa caché local
    if (kIsWeb) return;

    try {
      final db = await _db;

      // Obtiene la review actual
      final record = await _store.record(reviewId).get(db);
      print('record a eliminar $record');

      if (record == null) {
        throw 'Review no encontrada en caché';
      }

      // Marca como eliminada (soft delete)
      final updatedRecord = Map<String, dynamic>.from(record);
      updatedRecord['deletedAt'] = DateTime.now().millisecondsSinceEpoch;
      updatedRecord['isSynced'] = false; // Marca como no sincronizada

      // Actualiza el registro
      await _store.record(reviewId).put(db, updatedRecord);
    } catch (e) {
      throw 'Error al eliminar review del caché: $e';
    }
  }

  Future<List<ReviewModel>> getPendingReviews() async {
    // En web no hay pendientes locales
    if (kIsWeb) return [];
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
        return ReviewModel.fromSembastMap(record.key, record.value);
      }).toList();
    } catch (e) {
      throw 'Error al obtener reviews pendientes: $e';
    }
  }

  Future<void> markAsSynced(String reviewId) async {
    // En web no se usa caché local
    if (kIsWeb) return;

    try {
      final db = await _db;
      // Obtiene la review actual
      final record = await _store.record(reviewId).get(db);
      if (record == null) {
        throw 'Review no encontrada en caché';
      }

      // Marca como sincronizada
      final updatedRecord = Map<String, dynamic>.from(record);
      updatedRecord['isSynced'] = true;

      // Actualiza el registro
      await _store.record(reviewId).put(db, updatedRecord);
    } catch (e) {
      throw 'Error al marcar review como sincronizada: $e';
    }
  }

  Future<void> clearCache() async {
    // En web no se usa caché local
    if (kIsWeb) return;

    try {
      final db = await _db;

      // Limpia todo el store
      await _store.delete(db);
    } catch (e) {
      throw 'Error al limpiar caché de reviews: $e';
    }
  }

  Future<ReviewModel?> getUserReviewByEntity(
      String userId, String entityId) async {
    // En web no se usa caché local
    if (kIsWeb) return null;

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
      return ReviewModel.fromSembastMap(records.first.key, records.first.value);
    } catch (e) {
      throw 'Error al obtener review del usuario en caché: $e';
    }
  }

  Future<void> deleteLocalRecord(String recordId) async {
    // En web no se usa caché local
    if (kIsWeb) return;

    try {
      final db = await _db;

      // Elimina el registro físicamente (hard delete)
      await _store.record(recordId).delete(db);
    } catch (e) {
      throw 'Error al eliminar registro local: $e';
    }
  }

  
}
