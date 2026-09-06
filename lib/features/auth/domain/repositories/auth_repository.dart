import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/auth/data/models/auth_model.dart';

abstract class AuthRepository {
  Future<void> registerUser(AuthModel user);
  Future<UserCredential> authWithGoogle();
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User?> getAuthenticatedUser();
  Future<AuthModel> getUserData(String uid);
  Future<void> resetPassword(String email);
  Future<void> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  });
  Future<AuthModel> verifyOrCreateGoogleUser(UserCredential credential);

  Stream<AuthModel?> authStateChanges();
  Future<List<AuthModel>> getAllUsers();
}
