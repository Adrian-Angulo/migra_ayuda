import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String lastname;
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
    required this.lastname,
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
      'lastname': lastname,
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
      name: data['name'] ?? 'No data',
      lastname: data['lastname'] ?? 'No data',
      originCountry: data['originCountry'],
      destinationCountry: data['destinationCountry'],
      email: data['email'] ?? 'No data',
      age: data['age'] ?? "No data",
      password: data['password'] ?? '',
      role: data['role'] ?? 'Migrante',
      profileComplete: data['profileComplete'] ?? false,
      createdAt: _parseDate(data['registrationDate']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();

    return DateTime.now();
  }
}
