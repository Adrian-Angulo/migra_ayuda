import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class GetAuthenticatedUserUseCase {
  final AuthRepository _repository;

  GetAuthenticatedUserUseCase(this._repository);

  Future<UserModel?> call() async {
    try {
      final user = await _repository.getAuthenticatedUser();
      if (user == null) return null;
      if (!user.emailVerified) {
        await _repository.logout();
        return null;
      }
      return await _repository.getUserData(user.uid);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
