import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> registrarUsuario(Usuario user);
  Future<UserCredential?> authConGoogle();
  Future<User?> iniciarSesion(String email, String password);
  Future<void> cerrarSesion();
  Future<User?> usuarioAutenticado();
  Future<Usuario> datosDeUsuario(String uid);
  Future<void> restablecerContrasena(String email);
  Future<void> completarPerfil({
    required String originCountry,
    required String destinationCountry,
    required int age,
  });
  Future<Usuario> verificarOCrearUsuarioGoogle(UserCredential credential);
  
}
