import 'package:flutter/cupertino.dart';

class ErrorMappers {
  /// Obtener mensaje de error amigable
  static String getAuthErrorMessage(String error, BuildContext context) {
    if (error.contains('email-not-verified') ||
        error.contains('email_not_verified')) {
      return 'Debes verificar tu correo electrónico antes de iniciar sesión. Por favor revisa tu bandeja de entrada.';
    }

    switch (error) {
      case 'user-not-found':
      case 'user_not_found':
        return 'Usuario no encontrado. Por favor regístrate.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta de usuario ha sido inhabilitada.';
      case 'email-already-in-use':
      case 'email_already_in_use':
        return 'Este correo ya se encuentra registrado.';
      case 'operation-not-allowed':
        return 'Operación no permitida.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con una credencial diferente.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu conexión a internet.';
      default:
        return 'Error al iniciar sesión. Intenta nuevamente.';
    }
  }
}
