import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class RegisterUserUseCase {
  AuthRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<void> call(UserModel user) async {
    try {
      await _repository.registerUser(user);
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
