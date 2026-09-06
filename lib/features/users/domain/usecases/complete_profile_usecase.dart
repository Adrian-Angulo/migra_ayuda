import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';

class CompleteProfileUseCase {
  final UserRepository _repository;

  CompleteProfileUseCase(this._repository);

  Future<void> call({
    required String id,
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) {
    return _repository.completeProfile(
      id: id,
      originCountry: originCountry,
      destinationCountry: destinationCountry,
      age: age,
    );
  }
}
