import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/core/models/user_model.dart';

import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository _repository;

  LoginUser(this._repository);

  Future<UserModel?> call(String email, String password) async {
    try {
      await _repository.login(email, password);
      final user = await _repository.getUsuarioActual();
      if (user == null) throw Exception("El usuario no existe");
      return user;
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
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Sin conexión a internet. Verifica tu conexión';
      } else {
        errorMessage = e.message ?? e.toString();
      }
      throw Exception(errorMessage);
    }
  }
}
