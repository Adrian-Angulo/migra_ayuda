import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:sembast/sembast.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/features/reviews/data/models/review_model.dart';

class ReviewLocalDataSource {
  final SembastDatabase _sembastDatabase;
  final StoreRef<String, Map<String, dynamic>> _store = stringMapStoreFactory.store('reviews');

  ReviewLocalDataSource({required SembastDatabase sembastDatabase})
      : _sembastDatabase = sembastDatabase;

  /// Gets the Sembast database instance.
  Future<Database> get _db async => _sembastDatabase.database;

  bool get _isLocalCacheAvailable => !kIsWeb;

  Future<List<ReviewModel>> getCachedReviews() async {
    if (!_isLocalCacheAvailable) return [];
    try {
      final db = await _db;
      final finder = Finder(
        filter: Filter.isNull('deletedAt'),
        sortOrders: [SortOrder('createdAt', false)],
      );
      final records = await _store.find(db, finder: finder);
      return records
          .map((record) => ReviewModel.fromSembastMap(record.key, record.value))
          .toList();
    } catch (_) {
      throw 'Error al obtener reviews del caché';
    }
  }

  Future<List<ReviewModel>> getReviewsByEntity(String entityId) async {
    if (!_isLocalCacheAvailable) return [];
    try {
      final db = await _db;
      final finder = Finder(
        filter: Filter.and([
          Filter.equals('idEntity', entityId),
          Filter.isNull('deletedAt'),
        ]),
        sortOrders: [SortOrder('createdAt', false)],
      );
      final records = await _store.find(db, finder: finder);
      return records
          .map((record) => ReviewModel.fromSembastMap(record.key, record.value))
          .toList();
    } catch (e) {
      debugPrint('❌ Error en getReviewsByEntity: $e');
      throw 'Error al obtener reviews de la entidad del caché: $e';
    }
  }

  Future<void> cacheReview(ReviewModel review) async {
    if (!_isLocalCacheAvailable) return;
    try {
      final db = await _db;
      final localRecord = await _store.record(review.id).get(db);
      if (_shouldSkipOverwrite(localRecord)) return;
      await _store.record(review.id).put(db, review.toMap());
    } catch (e) {
      throw 'Error al guardar review en caché: $e';
    }
  }

  Future<void> cacheReviews(List<ReviewModel> reviews) async {
    if (!_isLocalCacheAvailable) return;
    try {
      final db = await _db;
      for (final review in reviews) {
        final localRecord = await _store.record(review.id).get(db);
        if (_shouldSkipOverwrite(localRecord)) continue;
        await _store.record(review.id).put(db, review.toMap());
      }
    } catch (e) {
      throw 'Error al guardar reviews en caché: $e';
    }
  }

  Future<void> deleteReview(String reviewId) async {
    if (!_isLocalCacheAvailable) return;
    try {
      final db = await _db;
      final record = await _store.record(reviewId).get(db);
      debugPrint('record a eliminar $record');
      if (record == null) throw 'Review no encontrada en caché';
      final updatedRecord = Map<String, dynamic>.from(record)
        ..['deletedAt'] = DateTime.now().toUtc().toIso8601String()
        ..['isSynced'] = false;
      await _store.record(reviewId).put(db, updatedRecord);
    } catch (e) {
      throw 'Error al eliminar review del caché: $e';
    }
  }

  Future<List<ReviewModel>> getPendingReviews() async {
    if (!_isLocalCacheAvailable) return [];
    try {
      final db = await _db;
      final finder = Finder(
        filter: Filter.equals('isSynced', false),
        sortOrders: [SortOrder('createdAt', false)],
      );
      final records = await _store.find(db, finder: finder);
      return records
          .map((record) => ReviewModel.fromSembastMap(record.key, record.value))
          .toList();
    } catch (e) {
      throw 'Error al obtener reviews pendientes: $e';
    }
  }

  Future<void> markAsSynced(String reviewId) async {
    if (!_isLocalCacheAvailable) return;
    try {
      final db = await _db;
      final record = await _store.record(reviewId).get(db);
      if (record == null) throw 'Review no encontrada en caché';
      final updatedRecord = Map<String, dynamic>.from(record)
        ..['isSynced'] = true;
      await _store.record(reviewId).put(db, updatedRecord);
    } catch (e) {
      throw 'Error al marcar review como sincronizada: $e';
    }
  }

  Future<void> clearCache() async {
    if (!_isLocalCacheAvailable) return;
    try {
      final db = await _db;
      await _store.delete(db);
    } catch (e) {
      throw 'Error al limpiar caché de reviews: $e';
    }
  }

  Future<ReviewModel?> getUserReviewByEntity(
      String userId, String entityId) async {
    if (!_isLocalCacheAvailable) return null;
    try {
      final db = await _db;
      final finder = Finder(
        filter: Filter.and([
          Filter.equals('idMigrante', userId),
          Filter.equals('idEntity', entityId),
          Filter.isNull('deletedAt'),
        ]),
        sortOrders: [SortOrder('createdAt', false)],
        limit: 1,
      );

      final records = await _store.find(db, finder: finder);
      if (records.isEmpty) return null;
      return ReviewModel.fromSembastMap(records.first.key, records.first.value);
    } catch (e) {
      throw 'Error al obtener review del usuario en caché: $e';
    }
  }

  Future<void> deleteLocalRecord(String recordId) async {
    if (!_isLocalCacheAvailable) return;
    try {
      final db = await _db;
      await _store.record(recordId).delete(db);
    } catch (e) {
      throw 'Error al eliminar registro local: $e';
    }
  }

  bool _shouldSkipOverwrite(Map<String, dynamic>? localRecord) {
    if (localRecord == null) return false;
    final isLocalSynced = localRecord['isSynced'] as bool? ?? true;
    final isLocalDeleted = localRecord['deletedAt'] != null;
    return !isLocalSynced || isLocalDeleted;
  }
}
