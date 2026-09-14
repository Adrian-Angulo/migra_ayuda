import 'package:equatable/equatable.dart';

/// Clase base para todos los errores de dominio (Failures)
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

// -------------------------------------------------------------
// ERRORES GENERALES DEL SISTEMA
// -------------------------------------------------------------
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Error en el servidor', super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Error de conexión. Verifica tu acceso a internet.',
    super.code,
  });
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'Ocurrió un error inesperado',
    super.code,
  });
}

// -------------------------------------------------------------
// ERRORES ESPECÍFICOS DE AUTENTICACIÓN (AuthFailure)
// -------------------------------------------------------------
abstract class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure({
    super.message = 'Correo o contraseña incorrectos',
    super.code = 'invalid-credential',
  });
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure({
    super.message = 'El correo electrónico ya está registrado',
    super.code = 'email-already-in-use',
  });
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure({
    super.message = 'La contraseña es muy débil. Debe tener al menos 6 caracteres',
    super.code = 'weak-password',
  });
}

class EmailNotVerifiedFailure extends AuthFailure {
  const EmailNotVerifiedFailure({
    super.message = 'Por favor verifica tu correo electrónico antes de ingresar',
    super.code = 'email-not-verified',
  });
}

class GoogleSignInCancelledFailure extends AuthFailure {
  const GoogleSignInCancelledFailure({
    super.message = 'El inicio de sesión con Google fue cancelado',
    super.code = 'google-sign-in-cancelled',
  });
}

class UserNotFoundAuthFailure extends AuthFailure {
  const UserNotFoundAuthFailure({
    super.message = 'No se encontró una cuenta con este correo',
    super.code = 'user-not-found',
  });
}

class GenericAuthFailure extends AuthFailure {
  const GenericAuthFailure({
    required super.message,
    super.code,
  });
}

// -------------------------------------------------------------
// ERRORES ESPECÍFICOS DE USUARIOS (UserFailure)
// -------------------------------------------------------------
abstract class UserFailure extends Failure {
  const UserFailure({required super.message, super.code});
}

class UserNotFoundFailure extends UserFailure {
  const UserNotFoundFailure({
    super.message = 'Usuario no encontrado',
    super.code = 'user-not-found',
  });
}

class UserProfileCreationFailedFailure extends UserFailure {
  const UserProfileCreationFailedFailure({
    super.message = 'Error al crear el perfil de usuario en la base de datos',
    super.code = 'profile-creation-failed',
  });
}

class UserProfileUpdateFailedFailure extends UserFailure {
  const UserProfileUpdateFailedFailure({
    super.message = 'Error al actualizar el perfil de usuario',
    super.code = 'profile-update-failed',
  });
}

class GenericUserFailure extends UserFailure {
  const GenericUserFailure({
    required super.message,
    super.code,
  });
}

// -------------------------------------------------------------
// ERRORES ESPECÍFICOS DE ONBOARDING (OnboardingFailure)
// -------------------------------------------------------------
abstract class OnboardingFailure extends Failure {
  const OnboardingFailure({required super.message, super.code});
}

class OnboardingStorageFailure extends OnboardingFailure {
  const OnboardingStorageFailure({
    super.message = 'Error al guardar el estado del onboarding',
    super.code = 'onboarding-storage-failed',
  });
}

class GenericOnboardingFailure extends OnboardingFailure {
  const GenericOnboardingFailure({
    required super.message,
    super.code,
  });
}
