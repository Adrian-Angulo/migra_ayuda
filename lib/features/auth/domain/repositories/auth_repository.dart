import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/core/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/entities/google_signin_result.dart';

abstract class AuthRepository {
  Future<void> register(
    String name,
    String lasname,
    String email,
    String password,
    String originCountry,
    String destinationCountry,
    int age,
  );
  Future<GoogleSignInResult> signInWithGoogle();
  Future<User?> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getUsuarioActual();
  Future<void> resetPassword(String email);
  Future<void> completeGoogleProfile({
    required String userId,
    required String originCountry,
    required String destinationCountry,
    required int age,
  });
}
