import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<void> call(String email) {
    return _repository.resetPassword(email);
  }
}
