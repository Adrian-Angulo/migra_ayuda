import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> loginWithEmail(String email, String password);
  Future<Either<Failure, AuthUser>> registerWithEmail(String email, String password);
  Future<Either<Failure, AuthUser>> authWithGoogle();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, AuthUser?>> getCurrentUser();
  Stream<AuthUser?> watchAuthState();
  Future<Either<Failure, void>> deleteCurrentUser();
}


