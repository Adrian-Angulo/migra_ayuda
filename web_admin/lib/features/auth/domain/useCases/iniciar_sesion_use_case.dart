import 'package:dartz/dartz.dart';
import 'package:migra_ayuda_administracion/core/errors/failures.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/repositories/auth_repository.dart';


class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String email, String password) async {
    final result = await _repository.login(email, password);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }
}
