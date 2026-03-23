import 'package:firebase_auth/firebase_auth.dart';

abstract class UserRepository {
  
  Future<void> createUser(User user, Map<String, dynamic> data);
}