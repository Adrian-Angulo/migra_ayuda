import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorMapper {
  static String mapError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No existe una cuenta con este correo';

        case 'wrong-password':
          return 'La contraseña es incorrecta';

        case 'invalid-email':
          return 'El correo no es válido';

        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada';

        case 'too-many-requests':
          return 'Demasiados intentos. Intenta más tarde';

        case 'network-request-failed':
          return 'Sin conexión a internet';

        default:
          return 'Error de autenticación';
      }
    }

    return 'Ocurrió un error inesperado';
  }
}