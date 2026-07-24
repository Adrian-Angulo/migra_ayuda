import 'package:firebase_auth/firebase_auth.dart';

class ErrorMappers {
    /// Obtener mensaje de error amigable
  static String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe un usuario con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'email-already-in-use':
        return 'Este correo ya está en uso';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este correo usando otro método';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      default:
        return e.message ?? 'Error de autenticación';
    }
  }
}