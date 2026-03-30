import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failures.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class CompleteProfileUseCase {
  final AuthRepository _repository;

  CompleteProfileUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    return await _repository.completeProfile(
      originCountry: originCountry,
      destinationCountry: destinationCountry,
      age: age,
    );
  }
}
