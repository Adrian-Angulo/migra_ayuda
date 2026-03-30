import 'package:migra_ayuda/core/errors/failures.dart';

// Failures base de autenticación
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Failures específicos por tipo de error de Firebase Auth
class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('Este correo ya está registrado');
}

class InvalidCredentialFailure extends AuthFailure {
  const InvalidCredentialFailure() : super('Correo o contraseña incorrecta');
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure() : super('El correo no es válido');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('La contraseña es demasiado débil');
}

class EmailNotVerifiedFailure extends AuthFailure {
  const EmailNotVerifiedFailure()
      : super('Debes verificar tu correo para iniciar sesión');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('El usuario no se encuentra registrado');
}

class OperationCancelledFailure extends AuthFailure {
  const OperationCancelledFailure() : super('Se canceló la operación');
}

class OperationNotAllowedFailure extends AuthFailure {
  const OperationNotAllowedFailure() : super('Operación no permitida');
}

class NetworkFailureAuth extends NetworkFailure {
  const NetworkFailureAuth() : super('Error de conexión a internet');
}

class UnexpectedFailure extends AuthFailure {
  const UnexpectedFailure() : super('Ocurrió un error inesperado');
}

class UserDataNotFoundFailure extends AuthFailure {
  const UserDataNotFoundFailure()
      : super('No se encontraron datos del usuario');
}
