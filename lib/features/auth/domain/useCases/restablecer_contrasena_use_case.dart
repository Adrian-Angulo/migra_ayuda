import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<void> call(String email) async {
    try {
      await _repository.resetPassword(email);
    } catch (e) {
      throw "Error al restablecer contraseña ${e.toString()}";
    }
  }
}
