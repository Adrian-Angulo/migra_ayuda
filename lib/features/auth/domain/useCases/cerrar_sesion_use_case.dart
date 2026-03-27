import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class CerrarSesionUseCase {
  final AuthRepository _repository;

  CerrarSesionUseCase(this._repository);

  Future<void> call() async {
    try {
      await _repository.cerrarSesion();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
