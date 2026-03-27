import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class UsuarioAutenticadoUseCase {
  final AuthRepository _repository;

  UsuarioAutenticadoUseCase(this._repository);

  Future<Usuario?> call() async {
    try {
      final usu = await _repository.usuarioAutenticado();
      if (usu == null) return null;
      if (!usu.emailVerified) {
        await _repository.cerrarSesion();
        return null;
      }
      ;
      return await _repository.datosDeUsuario(usu.uid);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
