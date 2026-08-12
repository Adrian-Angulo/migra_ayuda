import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/audit/data/models/audit_model.dart';

/// Implementación del datasource remoto usando Firebase Firestore
class AuditRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createActivity(AuditModel activity) async {
    try {
      // 2. Si no existe, crear nuevo documento con localId como clave de idempotencia
      final docRef = await _firestore
          .collection('user_activities')
          .add(activity.copyWith(isSynced: true).toMap());

      // Retorna el ID generado por Firebase
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear actividad de usuario en Firebase: $e');
    }
  }

  //metodo para obtener todas las acciones del usuario
  Stream<List<AuditModel>> getAllActivities() {
    return _firestore
        .collection('user_activities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return AuditModel(
            id: doc.id,
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
  Future<void> synchronize(List<AuditModel> activities) async {
    if (activities.isEmpty) return;
    for (final act in activities) {
      await createActivity(act.copyWith(isSynced: true));
    }
  }
}
