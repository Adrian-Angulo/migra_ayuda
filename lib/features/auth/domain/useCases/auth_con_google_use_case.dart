import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthWithGoogleUseCase {
  final AuthRepository _repository;

  AuthWithGoogleUseCase(this._repository);

  Future<UserModel?> call() async {
    try {
      final credential = await _repository.authWithGoogle();
      if (credential == null) throw "Se canceló la operación";

      final user = await _repository.verifyOrCreateGoogleUser(credential);
      return user;
    } catch (e) {
      throw e.toString();
    }
  }
}
