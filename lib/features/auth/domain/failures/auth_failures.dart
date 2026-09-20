import 'package:migra_ayuda/core/errors/failure.dart';

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
