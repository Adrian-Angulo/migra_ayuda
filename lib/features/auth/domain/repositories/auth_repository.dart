import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> registerUser(UserModel user);
  Future<UserCredential> authWithGoogle();
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User?> getAuthenticatedUser();
  Future<UserModel> getUserData(String uid);
  Future<void> resetPassword(String email);
  Future<void> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  });
  Future<UserModel> verifyOrCreateGoogleUser(UserCredential credential);

  Stream<UserModel?> authStateChanges();
  Future<List<UserModel>> getAllUsers();
}
