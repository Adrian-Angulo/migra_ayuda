import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class CompletarPerfilUseCase {
  final AuthRepository _repository;

  CompletarPerfilUseCase(this._repository);

  Future<void> call({
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    try {
      await _repository.completarPerfil(
        originCountry: originCountry,
        destinationCountry: destinationCountry,
        age: age,
      );
    } catch (e) {
      throw e.toString();
    }
  }
}
