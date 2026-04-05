import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/entities/admin_entity.dart';

class AdminModel extends AdminEntity {
  AdminModel({super.id = '', required super.email, required super.role});

  Map<String, dynamic> toMap() {
    return {'email': email, 'role': role};
  }

  factory AdminModel.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      id: doc.id,
      email: data['email'] ?? 'No data',
      role: data['role'] ?? 'Admin',
    );
  }
}
