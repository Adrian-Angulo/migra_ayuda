import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/entities/google_signin_result.dart';

abstract class AuthRepository {
  Future<void> registrarUsuario(Usuario user);
  Future<GoogleSignInResult> authConGoogle();
  Future<User?> iniciarSesion(String email, String password);
  Future<void> cerrarSesion();
  Future<User?> usuarioAutenticado();
  Future<Usuario> datosDeUsuario(String uid);
  Future<void> restablecerContrasena(String email);
  Future<void> completarPerfil({
    required String userId,
    required String originCountry,
    required String destinationCountry,
    required int age,
  });
}
