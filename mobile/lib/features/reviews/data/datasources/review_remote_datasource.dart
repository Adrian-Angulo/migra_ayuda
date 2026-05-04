import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/reviews/data/models/review_model.dart';

/// Excepción personalizada para errores del servidor
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

/// Interfaz abstracta para el datasource remoto de reviews
abstract class ReviewRemoteDataSource {
  /// Crea una nueva review en Firebase
  Future<String> createReview(ReviewModel review);

  /// Obtiene todas las reviews de Firebase
  Future<List<ReviewModel>> getAllReviews();

  /// Obtiene las reviews de una entidad específica de Firebase
  Future<List<ReviewModel>> getReviewsByEntity(String entityId);

  /// Actualiza una review existente en Firebase
  Future<void> updateReview(ReviewModel review);

  /// Elimina una review de Firebase
  Future<void> deleteReview(String reviewId);

  /// Obtiene la review de un usuario específico en una entidad de Firebase
  Future<ReviewModel?> getUserReviewByEntity(String userId, String entityId);
}

/// Implementación del datasource remoto usando Firebase Firestore
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final FirebaseFirestore _firestore;

  ReviewRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> createReview(ReviewModel review) async {
    try {
      // Crea el documento en Firestore
      final docRef = await _firestore.collection('reviews').add({
        'idMigrante': review.idMigrante,
        'idEntity': review.idEntity,
        'userName': review.userName,
        'userCountry': review.userCountry,
        'rating': review.rating,
        'comment': review.comment,
        'createdAt': review.createdAt.toIso8601String(),
        'updatedAt': review.updatedAt?.toIso8601String(),
        'deletedAt': review.deletedAt?.toIso8601String(),
        'isSynced': true, // En Firebase siempre está sincronizada
      });

      // Retorna el ID generado por Firebase
      return docRef.id;
    } catch (e) {
      throw ServerException('Error al crear review en Firebase: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getAllReviews() async {
    try {
      // Obtiene todas las reviews ordenadas por fecha de creación
      final snapshot = await _firestore
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      // Convierte los documentos a ReviewModel
      final reviews = snapshot.docs.map((doc) {
        return _fromFirestore(doc);
      }).toList();

      return reviews;
    } catch (e) {
      throw ServerException('Error al obtener reviews de Firebase: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsByEntity(String entityId) async {
    try {
      // Filtra por entityId y ordena por fecha
      final snapshot = await _firestore
          .collection('reviews')
          .where('idEntity', isEqualTo: entityId)
          .orderBy('createdAt', descending: true)
          .get();

      // Convierte los documentos a ReviewModel
      final reviews = snapshot.docs.map((doc) {
        return _fromFirestore(doc);
      }).toList();

      return reviews;
    } catch (e) {
      throw ServerException(
          'Error al obtener reviews de la entidad de Firebase: $e');
    }
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    try {
      // Actualiza el documento en Firestore
      await _firestore.collection('reviews').doc(review.id).update({
        'rating': review.rating,
        'comment': review.comment,
        'updatedAt': DateTime.now().toIso8601String(),
        'isSynced': true,
      });
    } catch (e) {
      throw ServerException('Error al actualizar review en Firebase: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      // Elimina el documento de Firestore (hard delete)
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw ServerException('Error al eliminar review de Firebase: $e');
    }
  }

  @override
  Future<ReviewModel?> getUserReviewByEntity(
      String userId, String entityId) async {
    try {
      // Filtra por userId (idMigrante) y entityId
      final snapshot = await _firestore
          .collection('reviews')
          .where('idMigrante', isEqualTo: userId)
          .where('idEntity', isEqualTo: entityId)
          .limit(1)
          .get();

      // Si no hay documentos, retorna null
      if (snapshot.docs.isEmpty) {
        return null;
      }

      // Convierte el primer documento a ReviewModel
      return _fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw ServerException(
          'Error al obtener review del usuario de Firebase: $e');
    }
  }

  /// Convierte un documento de Firestore a ReviewModel
  ReviewModel _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReviewModel(
      id: doc.id,
      idMigrante: data['idMigrante'] ?? '',
      idEntity: data['idEntity'] ?? '',
      userName: data['userName'] ?? '',
      userCountry: data['userCountry'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      deletedAt:
          data['deletedAt'] != null ? DateTime.parse(data['deletedAt']) : null,
      isSynced: data['isSynced'] ?? true,
    );
  }
}
