import 'package:migra_ayuda/features/reviews/data/datasources/utils.dart';
import 'package:sembast/sembast.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/features/reviews/data/models/review_model.dart';

class ReviewLocalDataSource {
  final SembastDatabase _sembastDatabase = SembastDatabase.instance;
  final StoreRef<String, Map<String, dynamic>> _store =
      stringMapStoreFactory.store('reviews');

  ReviewLocalDataSource();

  Future<Database> get _db async => _sembastDatabase.database;

  Future<void> createReview(ReviewModel review) async {
    final db = await _db;
    try {
      await _store.record(review.id).put(db, review.toMap());

    } catch (e) {
      throw 'Error al guardar review en la base de datos local: $e';
    }
  }
  Future<List<ReviewModel>> getReviewsByEntity(String entityId) async {
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
      throw 'Ha Ocurrido un error inesperado';
    }
  }

  Future<void> updateReview(ReviewModel review) async {
    try {
      final db = await _db;
      await _store.record(review.id).put(db, review.toMap());
    } catch (e) {
      throw 'Error al actualizar review';
    }
  }


  Future<void> createReviews(List<ReviewModel> reviews) async {
    try {
      final db = await _db;
      for (final review in reviews) {
        final localRecord = await _store.record(review.id).get(db);
        if (shouldPreserveLocalRecord(localRecord)) continue;
        await _store.record(review.id).put(db, review.toMap());
      }
    } catch (e) {
      throw 'Error al guardar reviews en caché: $e';
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final db = await _db;
      final record = await _store.record(reviewId).get(db);

      if (record == null) {
        throw Exception('Review no encontrada');
      }

      final updatedRecord = {
        ...record,
        'deletedAt': DateTime.now().toUtc().toIso8601String(),
        'isSynced': false,
      };

      await _store.record(reviewId).put(db, updatedRecord);
    } catch (e) {
      throw Exception('Error al eliminar review');
    }
  }

  Future<ReviewModel> getReviewById(String reviewId) async {
    try {
      final db = await _db;
      final record = await _store.record(reviewId).get(db);
      if (record == null) return throw Exception('review no encontrada');
      return ReviewModel.fromSembastMap(reviewId, record);
    } catch (e) {
      throw Exception('Error al obtener la review');
    }
  }

  Future<List<ReviewModel>> getPendingReviews() async {
    try {
      final db = await _db;

      final pendingReviewsFinder = Finder(
        filter: Filter.equals('isSynced', false),
        sortOrders: [SortOrder('createdAt', false)],
      );

      final pendingRecords =
          await _store.find(db, finder: pendingReviewsFinder);

      return pendingRecords
          .map((record) => ReviewModel.fromSembastMap(record.key, record.value))
          .toList();
    } catch (error) {
      throw 'Error al obtener reviews pendientes';
    }
  }

  Future<void> markAsSynced(String reviewId) async {
    try {
      final db = await _db;
      final record = await _store.record(reviewId).get(db);

      if (record == null) {
        throw Exception('Review no encontrada en caché');
      }

      final updatedRecord = {
        ...record,
        'isSynced': true,
      };

      await _store.record(reviewId).put(db, updatedRecord);
    } catch (e) {
      throw Exception('Error al marcar review como sincronizada: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final db = await _db;
      await _store.delete(db);
    } catch (e) {
      throw Exception('Error al limpiar caché de reviews');
    }
  }

  Future<void> deleteLocalRecord(String recordId) async {
    try {
      final db = await _db;
      await _store.record(recordId).delete(db);
    } catch (e) {
      throw 'Error al eliminar registro local: $e';
    }
  }
}
