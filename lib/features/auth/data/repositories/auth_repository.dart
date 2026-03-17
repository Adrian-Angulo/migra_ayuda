import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';

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
  Future<UserCredential> login(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getCurrentUserId();
  Future<void> resetPassword(String email);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount();
  Future<void> refreshToken();
  Future<UserCredential?> signInWithGoogle();
  Future<bool> isProfileComplete();
  Future<void> completeGoogleProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
    required bool aceptaTerminos,
  });
  Future<UserModel?> getUsuarioActual();
}
