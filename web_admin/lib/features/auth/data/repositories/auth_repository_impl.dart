import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda_administracion/core/errors/auth_failures.dart';
import 'package:migra_ayuda_administracion/core/errors/failures.dart';
import 'package:migra_ayuda_administracion/features/auth/data/models/admin_model.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/entities/admin_entity.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _auth.signOut();
      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AdminEntity>> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return const Left(UserDataNotFoundFailure());
      }

      return Right(AdminModel.fromMap(doc));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al obtener datos'));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(UserNotFoundFailure());
      }

      if (!credential.user!.emailVerified) {
        return const Left(EmailNotVerifiedFailure());
      }

      return Right(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthError(e.code));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthError(e.code));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getAuthenticatedUser() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return const Left(UserNotFoundFailure());
      }

      return Right(user);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  // Helper method para mapear errores de Firebase
  Failure _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return const EmailAlreadyInUseFailure();
      case 'invalid-credential':
        return const InvalidCredentialFailure();
      case 'invalid-email':
        return const InvalidEmailFailure();
      case 'weak-password':
        return const WeakPasswordFailure();
      case 'operation-not-allowed':
        return const OperationNotAllowedFailure();
      case 'network-request-failed':
        return const NetworkFailureAuth();
      case 'user-not-found':
        return const UserNotFoundFailure();
      default:
        return const UnexpectedFailure();
    }
  }
}
