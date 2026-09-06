import 'package:migra_ayuda/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> loginWithEmail(String email, String password);
  Future<AuthUser> registerWithEmail(String email, String password);
  Future<AuthUser> authWithGoogle();
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<AuthUser?> getCurrentUser();
  Stream<AuthUser?> watchAuthState();
  Future<void> deleteCurrentUser();
}


