import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failures.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthWithGoogleUseCase {
  final AuthRepository _repository;

  AuthWithGoogleUseCase(this._repository);

  Future<Either<Failure, UserModel>> call() async {
    final credentialResult = await _repository.authWithGoogle();

    return credentialResult.fold(
      (failure) => Left(failure),
      (credential) async {
        return await _repository.verifyOrCreateGoogleUser(credential);
      },
    );
  }
}
