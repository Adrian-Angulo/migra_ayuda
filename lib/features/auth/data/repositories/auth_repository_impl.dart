import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:migra_ayuda/features/auth/data/mappers/auth_exception_mapper.dart';
import 'package:migra_ayuda/features/auth/domain/entities/auth_user.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  @override
  Future<Either<Failure, AuthUser>> loginWithEmail(
      String email, String password) async {
    try {
      final user = await _remoteDataSource.loginWithEmail(email, password);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthExceptionMapper.fromFirebaseAuthException(e));
    } catch (e) {
      if (e.toString().contains('email-not-verified')) {
        return const Left(EmailNotVerifiedFailure());
      }
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AuthUser>> registerWithEmail(
      String email, String password) async {
    try {
      final user = await _remoteDataSource.registerWithEmail(email, password);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthExceptionMapper.fromFirebaseAuthException(e));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AuthUser>> authWithGoogle() async {
    try {
      final user = await _remoteDataSource.authWithGoogle();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthExceptionMapper.fromFirebaseAuthException(e));
    } catch (e) {
      if (e.toString().contains('cancel') ||
          e.toString().contains('google-sign-in-cancelled')) {
        return const Left(GoogleSignInCancelledFailure());
      }
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthExceptionMapper.fromFirebaseAuthException(e));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _remoteDataSource.resetPassword(email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthExceptionMapper.fromFirebaseAuthException(e));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthExceptionMapper.fromFirebaseAuthException(e));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Stream<AuthUser?> watchAuthState() {
    return _remoteDataSource.watchAuthState();
  }

  @override
  Future<Either<Failure, void>> deleteCurrentUser() async {
    try {
      await _remoteDataSource.deleteCurrentUser();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthExceptionMapper.fromFirebaseAuthException(e));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }
}
