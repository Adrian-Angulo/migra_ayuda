import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class CompleteProfileUseCase {
  final AuthRepository _repository;

  CompleteProfileUseCase(this._repository);

  Future<void> call({
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    try {
      await _repository.completeProfile(
        originCountry: originCountry,
        destinationCountry: destinationCountry,
        age: age,
      );
    } catch (e) {
      throw e.toString();
    }
  }
}
