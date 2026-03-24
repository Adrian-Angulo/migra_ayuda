import 'package:migra_ayuda/features/auth/domain/entities/google_signin_result.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthWithGoogle {
  final AuthRepository _repository;
  AuthWithGoogle(this._repository);

  Future<GoogleSignInResult> call() async {
    try {
      return await _repository.signInWithGoogle();
    } catch (e) {
      throw Exception(e);
    }
  }
}
