import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failures.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<Either<Failure, void>> call(UserModel user) async {
    return await _repository.registerUser(user);
  }
}
