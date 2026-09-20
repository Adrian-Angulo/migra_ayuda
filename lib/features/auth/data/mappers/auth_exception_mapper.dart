import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/auth/domain/failures/auth_failures.dart';

/// Mapper responsable de convertir excepciones técnicas de FirebaseAuth en Failures de dominio
class AuthExceptionMapper {
  static Failure fromFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const UserNotFoundAuthFailure();
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return const InvalidCredentialsFailure();
      case 'email-already-in-use':
        return const EmailAlreadyInUseFailure();
      case 'weak-password':
        return const WeakPasswordFailure();
      case 'network-request-failed':
        return const NetworkFailure();
      default:
        return const UnexpectedFailure();
    }
  }
}

