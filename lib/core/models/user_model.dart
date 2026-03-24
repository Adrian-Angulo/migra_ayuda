import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String lastname;
  final String originCountry;
  final String destinationCountry;
  final String email;
  final int age;
  final String password;
  final String role;
  final bool profileComplete;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.lastname,
    required this.originCountry,
    required this.destinationCountry,
    required this.email,
    required this.age,
    required this.password,
    required this.role,
    required this.profileComplete,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'lastname': lastname,
      'originCountry': originCountry,
      'destinationCountry': destinationCountry,
      'email': email,
      'age': age,
      'password': password,
      'role': role,
      'profileComplete': profileComplete,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? 'No data',
      lastname: data['lastname'] ?? "No data",
      originCountry: data['originCountry'] ?? "No data",
      destinationCountry: data['destinationCountry'] ?? "No data",
      email: data['email'] ?? "No data",
      age: data['age'] != null ? int.parse(data['age'].toString()) : 0,
      password: data['password'] ?? '',
      role: data['role'] ?? 'Migrante',
      profileComplete: data['profileComplete'] ?? true,
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
