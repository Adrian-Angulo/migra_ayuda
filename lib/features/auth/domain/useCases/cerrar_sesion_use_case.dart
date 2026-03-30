import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() async {
    try {
      await _repository.logout();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
