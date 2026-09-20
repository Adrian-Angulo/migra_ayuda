
import 'package:migra_ayuda/core/errors/failure.dart';

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