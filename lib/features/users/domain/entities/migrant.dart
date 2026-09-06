import 'package:migra_ayuda/features/users/domain/entities/user.dart';

class Migrant extends UserEntity {
  final String originCountry;
  final String destinationCountry;
  final String age;
  final String role;
  final bool profileComplete;
  final DateTime createdAt;

  Migrant({
    required super.id,
    required super.name,
    required super.email,
    required this.originCountry,
    required this.destinationCountry,
    required this.age,
    this.role = 'Migrante',
    this.profileComplete = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Migrant copyWith({
    String? id,
    String? name,
    String? email,
    String? originCountry,
    String? destinationCountry,
    String? age,
    String? role,
    bool? profileComplete,
    DateTime? createdAt,
  }) {
    return Migrant(
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
