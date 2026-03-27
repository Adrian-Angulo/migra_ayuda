import 'package:firebase_auth/firebase_auth.dart';

import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class IniciarSesionUseCase {
  final AuthRepository _repository;
  IniciarSesionUseCase(this._repository);

  Future<void> call(String email, String password) async {
    try {
      final user = await _repository.iniciarSesion(email, password);
      if (user == null) throw "El usuario no se encuentra registrado";
      if (!user.emailVerified) throw "Debes verificar tu correo para iniciar sesión";
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e.code);
    } catch (e) {
      rethrow;
    }
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado';

      case 'invalid-credential':
        return 'correo o contraseña incorrecta';

      case 'weak-password':
        return 'La contraseña es demasiado débil';

      case 'operation-not-allowed':
        return 'Operación no permitida';

      case 'network-request-failed':
        return 'Error de conexión a internet';

      default:
        return "Ocurrio un erro inesperado";
    }
  }
}
