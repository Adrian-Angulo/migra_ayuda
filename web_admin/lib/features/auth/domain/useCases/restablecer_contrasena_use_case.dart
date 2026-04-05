import 'package:dartz/dartz.dart';
import 'package:migra_ayuda_administracion/core/errors/failures.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/repositories/auth_repository.dart';


class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String email) async {
    return await _repository.resetPassword(email);
  }
}
