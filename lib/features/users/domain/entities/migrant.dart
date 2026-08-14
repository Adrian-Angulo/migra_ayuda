import 'package:migra_ayuda/features/users/domain/entities/user.dart';

class Migrant extends UserEntity {
  final String originCountry;
  final String destinationCountry;
  final String age;
  final String password;
  final String role;
  final bool profileComplete;
  final DateTime createdAt;

  Migrant(
      {required super.id,
      required super.name,
      required super.email,
      required this.originCountry,
      required this.destinationCountry,
      required this.age,
      required this.password,
      required this.role,
      required this.profileComplete,
      required this.createdAt});
}
