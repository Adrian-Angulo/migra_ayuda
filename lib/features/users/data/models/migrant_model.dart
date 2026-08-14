import 'package:migra_ayuda/features/users/data/models/user_model.dart';

class MigrantModel extends UserModel {
  final String originCountry;
  final String destinationCountry;
  final String age;

  String role;
  final bool profileComplete;
  final DateTime createdAt;

  MigrantModel(
      {required super.id,
      required super.name,
      required super.email,
      required this.originCountry,
      required this.destinationCountry,
      required this.age,
      this.role = 'Migrante',
      required this.profileComplete,
      required this.createdAt});

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'originCountry': originCountry,
      'destinationCountry': destinationCountry,
      'age': age,
      'role': role,
      'profileComplete': profileComplete,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory MigrantModel.fromMap(Map<String, dynamic> map) {
    return MigrantModel(
      id: map['id'] ?? '-',
      name: map['name']?.toString() ?? '-',
      email: map['email']?.toString() ?? '-',
      originCountry: map['originCountry']?.toString() ?? '-',
      destinationCountry: map['destinationCountry']?.toString() ?? '-',
      age: map['age']?.toString() ?? '-',
      role: map['role']?.toString() ?? '-',
      profileComplete: (map['profileComplete'] is bool)
          ? map['profileComplete']
          : (map['profileComplete']?.toString().toLowerCase() == 'true'),
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  @override
  MigrantModel copyWith({
    String? id,
    String? name,
    String? email,
    String? originCountry,
    String? destinationCountry,
    String? age,
    String? password,
    String? role,
    bool? profileComplete,
    DateTime? createdAt,
  }) {
    return MigrantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      originCountry: originCountry ?? this.originCountry,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      age: age ?? this.age,
      role: role ?? this.role,
      profileComplete: profileComplete ?? this.profileComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
