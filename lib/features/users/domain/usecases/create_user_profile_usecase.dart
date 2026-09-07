import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';

class CreateUserProfileUseCase {
  final UserRepository _repository;

  CreateUserProfileUseCase(this._repository);

  Future<Either<Failure, void>> call(Migrant user) {
    return _repository.createUser(user);
  }
}
