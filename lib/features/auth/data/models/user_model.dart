import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String? originCountry;
  final String? destinationCountry;
  final String email;
  final String? age;
  final String password;
  final String role;
  final bool profileComplete;
  final DateTime createdAt;

  UserModel({
    this.id = '',
    required this.name,
    this.originCountry,
    this.destinationCountry,
    required this.email,
    this.age,
    required this.password,
    this.role = 'Migrante',
    this.profileComplete = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'originCountry': originCountry,
      'destinationCountry': destinationCountry,
      'email': email,
      'age': age,
      'role': role,
      'profileComplete': profileComplete,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '-',
      originCountry: data['originCountry'] ?? '-',
      destinationCountry: data['destinationCountry'] ?? '-',
      email: data['email'] ?? '-',
      age: data['age'] ?? "-",
      password: data['password'] ?? '',
      role: data['role'] ?? 'Migrante',
      profileComplete: data['profileComplete'] ?? false,
      // Intenta leer primero 'createdAt', luego 'registrationDate' como fallback
      createdAt: _parseDate(data['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    // Si el valor es null, retornar fecha actual
    if (value == null) {
      print('⚠️  [UserModel] Campo de fecha es null, usando fecha actual');
      return DateTime.now();
    }

    // Si es un Timestamp de Firestore, convertirlo a DateTime
    if (value is Timestamp) {
      return value.toDate();
    }

    // Si es un String ISO8601, parsearlo
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      } else {
        print('⚠️  [UserModel] No se pudo parsear la fecha: $value');
        return DateTime.now();
      }
    }

    print('⚠️  [UserModel] Tipo de fecha desconocido: ${value.runtimeType}');
    return DateTime.now();
  }
}
