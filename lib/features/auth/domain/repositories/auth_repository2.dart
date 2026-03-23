
import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/core/models/user_model.dart';

abstract class AuthRepository2 {
    Future<void> register(
    String name,
    String lasname,
    String email,
    String password,
    String originCountry,
    String destinationCountry,
    int age,
  );
  Future<UserCredential?> signInWithGoogle();
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getUsuarioActual();
  Future<void> resetPassword(String email);
}