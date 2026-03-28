import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class RestablecerContrasenaUseCase {
  final AuthRepository _repository;

  RestablecerContrasenaUseCase(this._repository);

  Future<void> call(String email) async {
    try {
      await _repository.restablecerContrasena(email);
    } catch (e) {
      throw "Error al restablecer contraseña ${e.toString()}";
    }
  }
}
