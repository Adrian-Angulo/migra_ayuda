import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:migra_ayuda_administracion/features/userActivity/data/models/user_activity_model.dart';

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

  /// Retorna un Stream con la lista de actividades de usuario en tiempo real.
  /// Opcionalmente filtra por [idUser] para obtener solo las actividades de un usuario específico.
  Future<List<UserActivityModel>> getActivities({String? idUser}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('user_activities')
          .orderBy('createdAt', descending: true);

      if (idUser != null) {
        query = query.where('idUser', isEqualTo: idUser);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserActivityModel(
          id: data['localId'] as String? ?? doc.id,
          idUser: data['idUser'] as String,
          accion: data['accion'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          isSynced: data['isSynced'] as bool? ?? true,
        );
      }).toList();
    } catch (e) {
      throw ServerException('Error al obtener las actividades de usuario: $e');
    }
  }
}
