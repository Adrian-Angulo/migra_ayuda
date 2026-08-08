import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/userActivity/data/models/user_activity_model.dart';



/// Implementación del datasource remoto usando Firebase Firestore
class UserActivityRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createActivity(UserActivityModel activity) async {
    try {
     /*  // 1. Verificar si ya existe un documento con este localId (idempotencia)
      final existingQuery = await _firestore
          .collection('user_activities')
          .where('localId', isEqualTo: activity.id)
          .limit(1)
          .get();

      // Si ya existe, retornar su ID en lugar de crear duplicado
      if (existingQuery.docs.isNotEmpty) {
        return existingQuery.docs.first.id;
      } */


      // 2. Si no existe, crear nuevo documento con localId como clave de idempotencia
      final docRef = await _firestore.collection('user_activities').add({
        'localId': activity.id, 
        'idUser': activity.idUser,
        'accion': activity.accion,
        "nombre": activity.nombre,
        "correo": activity.correo,
        'pais': activity.pais,
        'createdAt': activity.createdAt.toIso8601String(),
        'isSynced': true, // En Firebase siempre está sincronizada
        'metadata': activity.metadata
      });

      // Retorna el ID generado por Firebase
      return docRef.id;
    } catch (e) {
      throw Exception(
          'Error al crear actividad de usuario en Firebase: $e');
    }
  }

  //metodo para obtener todas las acciones del usuario
  Stream<List<UserActivityModel>> getAllActivities() {
    return _firestore
        .collection('user_activities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return UserActivityModel(
            id: data['localId'] as String,
            idUser: data['idUser'] as String,
            accion: data['accion'] ?? "null",
            createdAt: DateTime.parse(data['createdAt'] as String),
            isSynced: data['isSynced'] as bool? ?? true,
            nombre: data['nombre'] ?? '',
            correo: data['correo'] ?? '',
            pais: data['pais'] ?? '',
            metadata: data['metadata'] != null
                ? Map<String, dynamic>.from(data['metadata'] as Map)
                : null);
      }).toList();
    }).handleError((e) {
      throw Exception(
          'Error al obtener actividades de usuario desde Firebase: $e');
    });
  }

  //Metodo para subir actividades pendientes a firebase
  Future<void> synchronize(List<UserActivityModel> activities) async {
    if (activities.isEmpty) return;
    for (final act in activities) {
      await _firestore.collection('user_activities').add(act.copyWith(isSynced: true).toMap());
    }
  }
}
