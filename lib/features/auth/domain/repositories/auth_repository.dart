import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> registerUser(UserModel user);
  Future<firebase_auth.UserCredential?> authWithGoogle();
  Future<firebase_auth.User?> login(String email, String password);
  Future<void> logout();
  Future<firebase_auth.User?> getAuthenticatedUser();
  Future<UserModel> getUserData(String uid);
  Future<void> resetPassword(String email);
  Future<void> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  });
  Future<UserModel> verifyOrCreateGoogleUser(
      firebase_auth.UserCredential credential);
}
