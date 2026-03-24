import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository _repository;

  ResetPassword(this._repository);

  Future<void> call(String email) async {
    try {
      await _repository.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Error al enviar el correo. Intenta de nuevo');
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'invalid-email':
        return 'El formato del correo es inválido';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu conexión';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e intenta de nuevo';
      default:
        return 'Error al enviar el correo. Intenta de nuevo';
    }
  }
}
