import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthConGoogleUseCase {
  final AuthRepository _repository;

  AuthConGoogleUseCase(this._repository);

  Future<Usuario?> call() async {
    try {
      final credential = await _repository.authConGoogle();
      if (credential == null) throw "Se canceló la operación";

      // Verificar si el usuario existe en Firestore o crearlo
      final usuario =
          await _repository.verificarOCrearUsuarioGoogle(credential);
      return usuario;
    } catch (e) {
      throw e.toString();
    }
  }
}
