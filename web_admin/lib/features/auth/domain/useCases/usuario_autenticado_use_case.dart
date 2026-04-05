import 'package:dartz/dartz.dart';

import 'package:migra_ayuda_administracion/core/errors/failures.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/entities/admin_entity.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/repositories/auth_repository.dart';

class GetAuthenticatedUserUseCase {
  final AuthRepository _repository;

  GetAuthenticatedUserUseCase(this._repository);

  Future<Either<Failure, AdminEntity?>> call() async {
    final result = await _repository.getAuthenticatedUser();

    return result.fold((failure) => Left(failure), (user) async {
      if (!user.emailVerified) {
        await _repository.logout();
        return const Right(null);
      }
      return await _repository.getUserData(user.uid);
    });
  }
}
