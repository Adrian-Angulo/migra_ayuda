import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class CompleteGoogleProfile {
  final AuthRepository _repository;

  CompleteGoogleProfile(this._repository);

  Future<void> call({
    required String userId,
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    try {
      await _repository.completeGoogleProfile(
        userId: userId,
        originCountry: originCountry,
        destinationCountry: destinationCountry,
        age: age,
      );
    } catch (e) {
      throw Exception("Error al completar perfil: $e");
    }
  }
}
