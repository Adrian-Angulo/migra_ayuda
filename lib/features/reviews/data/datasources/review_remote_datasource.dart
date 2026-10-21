import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/reviews/data/models/review_model.dart';

/// Excepción personalizada para errores del servidor
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}


class ReviewRemoteDataSource {
  final FirebaseFirestore _firestore;

  ReviewRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveReview(ReviewModel review) async {
    try {
      final reviewToSave = review.copyWith(isSynced: true);
      await _firestore
          .collection('reviews')
          .doc(review.id)
          .set(reviewToSave.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Error al guardar review en Firebase: $e');
    }
  }

  Future<void> createReview(ReviewModel review) async {
    await saveReview(review);
  }

  Future<List<ReviewModel>> getAllReviews() async {
    try {
      
      final snapshot = await _firestore
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      
      final reviews = snapshot.docs.map((doc) {
        return _fromFirestore(doc);
      }).toList();

      return reviews;
    } catch (e) {
      throw ServerException('Error al obtener reviews de Firebase: $e');
    }
  }

  Future<List<ReviewModel>> getReviewsByEntity(String entityId) async {
    try {
    
      final snapshot = await _firestore
          .collection('reviews')
          .where('idEntity', isEqualTo: entityId)
          .get();

    
      final reviews = snapshot.docs.map((doc) {
        return _fromFirestore(doc);
      }).toList();

      return reviews;
    } catch (e) {
      throw ServerException(
          'Error al obtener reviews de la entidad de Firebase: $e');
    }
  }

  Future<void> updateReview(ReviewModel review) async {
    await saveReview(review);
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw ServerException('Error al eliminar review de Firebase: $e');
    }
  }

  Future<ReviewModel?> getUserReviewByEntity(
      String userId, String entityId) async {
    try {
      
      final snapshot = await _firestore
          .collection('reviews')
          .where('idMigrante', isEqualTo: userId)
          .where('idEntity', isEqualTo: entityId)
          .limit(1)
          .get();

      
      if (snapshot.docs.isEmpty) {
        return null;
      }

      
      return _fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw ServerException(
          'Error al obtener review del usuario de Firebase: $e');
    }
  }

  
  ReviewModel _fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ReviewModel(
      id: doc.id,
      idMigrante: data['idMigrante'] ?? '',
      idEntity: data['idEntity'] ?? '',
      userName: data['userName'] ?? '',
      userCountry: data['userCountry'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] ?? '',
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseNullableDateTime(data['updatedAt']),
      deletedAt: _parseNullableDateTime(data['deletedAt']),
      isSynced: data['isSynced'] ?? true,
      nameEntity: data['nameEntity'] ?? '',
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
