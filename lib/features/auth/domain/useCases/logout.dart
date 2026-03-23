import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class Logout {
  final AuthRepository _repository;

  Logout(this._repository);

  Future<void> call() async {
    try {
      await _repository.logout();
    } catch (e) {
      throw Exception("$e");
    }
  }
}
