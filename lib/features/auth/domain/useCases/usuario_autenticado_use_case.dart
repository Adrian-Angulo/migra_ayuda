import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failures.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class GetAuthenticatedUserUseCase {
  final AuthRepository _repository;

  GetAuthenticatedUserUseCase(this._repository);

  Future<Either<Failure, UserModel?>> call() async {
    final result = await _repository.getAuthenticatedUser();

    return result.fold(
      (failure) => Left(failure),
      (user) async {
        if (!user.emailVerified) {
          await _repository.logout();
          return const Right(null);
        }
        return await _repository.getUserData(user.uid);
      },
    );
  }
}
