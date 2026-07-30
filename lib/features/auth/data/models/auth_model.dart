import 'package:cloud_firestore/cloud_firestore.dart';

class AuthModel {
  final String email;
  final String? password;
  final String role;

  AuthModel({required this.email, required this.password, required this.role});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory AuthModel.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuthModel(email: data['email'], role: data['role'], password: '');
  }
}
