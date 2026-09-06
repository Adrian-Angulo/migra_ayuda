import 'package:migra_ayuda/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:migra_ayuda/features/auth/domain/entities/auth_user.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  @override
  Future<AuthUser> loginWithEmail(String email, String password) {
    return _remoteDataSource.loginWithEmail(email, password);
  }

  @override
  Future<AuthUser> registerWithEmail(String email, String password) {
    return _remoteDataSource.registerWithEmail(email, password);
  }

  @override
  Future<AuthUser> authWithGoogle() {
    return _remoteDataSource.authWithGoogle();
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }

  @override
  Future<void> resetPassword(String email) {
    return _remoteDataSource.resetPassword(email);
  }

  @override
  Future<AuthUser?> getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Stream<AuthUser?> watchAuthState() {
    return _remoteDataSource.watchAuthState();
  }

  @override
  Future<void> deleteCurrentUser() {
    return _remoteDataSource.deleteCurrentUser();
  }
}


