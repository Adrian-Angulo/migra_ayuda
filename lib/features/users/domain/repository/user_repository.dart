
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';

abstract class UserRepository {
  Future<Migrant?> getUserById(String id);
  Future<void> createUser(Migrant user);
  Future<void> completeProfile({
    required String id,
    required String originCountry,
    required String destinationCountry,
    required int age,
  });
  Stream<List<Migrant>> getAllUsers();
}

