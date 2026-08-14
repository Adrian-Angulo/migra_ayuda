import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';

abstract class UserRepository {
  Stream<List<Migrant>> getAllUsers();

}
