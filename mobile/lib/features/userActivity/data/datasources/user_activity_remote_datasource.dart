import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/userActivity/data/models/user_activity_model.dart';

/// Excepción personalizada para errores del servidor
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}



/// Implementación del datasource remoto usando Firebase Firestore
class UserActivityRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    
  Future<String> createActivity(UserActivityModel activity) async {
    try {
      // 1. Verificar si ya existe un documento con este localId (idempotencia)
      final existingQuery = await _firestore
          .collection('user_activities')
          .where('localId', isEqualTo: activity.id)
          .limit(1)
          .get();

      // Si ya existe, retornar su ID en lugar de crear duplicado
      if (existingQuery.docs.isNotEmpty) {
        return existingQuery.docs.first.id;
      }

      // 2. Si no existe, crear nuevo documento con localId como clave de idempotencia
      final docRef = await _firestore.collection('user_activities').add({
        'localId': activity.id, // Clave de idempotencia
        'idUser': activity.idUser,
        'accion': activity.accion,
        'createdAt': activity.createdAt.toIso8601String(),
        'isSynced': true, // En Firebase siempre está sincronizada
      });

      // Retorna el ID generado por Firebase
      return docRef.id;
    } catch (e) {
      throw ServerException(
          'Error al crear actividad de usuario en Firebase: $e');
    }
  }
}
