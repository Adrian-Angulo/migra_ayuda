import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository _repository;

  LoginUser(this._repository);

  Future<void> call(String email, String password) async {
    try {
      final user = await _repository.login(email, password);
      if (!user!.emailVerified) {
        //cerrar sesion
        await _repository.logout();
        throw FirebaseAuthException(
            code: 'email-not-verified',
            message:
                'Verifica tu correo antes de iniciar sesión. Revisa tu bandeja de spam en el correo');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No existe una cuenta con este correo';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El correo no es válido';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Esta cuenta fue deshabilitada';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Demasiados intentos, espera un momento';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Correo y/o contraseña invalidas';
      } else if (e.code == 'email-not-verified') {
        errorMessage =
            'Debes verificar tu correo antes de iniciar sesión. Revisa tu bandeja de entrada y spam.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Sin conexión a internet. Verifica tu conexión';
      } else {
        errorMessage = e.message ?? e.toString();
      }
      throw Exception(errorMessage);
    }
  }
}
