import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class RegistrarUsuarioUseCase {
  AuthRepository _repository;

  RegistrarUsuarioUseCase(this._repository);

  Future<void> call(Usuario usu) async {
    try {
      await _repository.registrarUsuario(usu);
      
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw Exception("Ocurrió un error inesperado");
    }
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado';

      case 'invalid-email':
        return 'El correo no es válido';

      case 'weak-password':
        return 'La contraseña es demasiado débil';

      case 'operation-not-allowed':
        return 'Operación no permitida';

      case 'network-request-failed':
        return 'Error de conexión a internet';

      default:
        return 'Ocurrió un error, intenta nuevamente';
    }
  }
}
