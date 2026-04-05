import 'package:dartz/dartz.dart';
import 'package:migra_ayuda_administracion/core/errors/failures.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/repositories/auth_repository.dart';


class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, Unit>> call() async {
    return await _repository.logout();
  }
}
