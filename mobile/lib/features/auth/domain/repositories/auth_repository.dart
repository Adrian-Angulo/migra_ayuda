import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:migra_ayuda/core/errors/failures.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> registerUser(UserModel user);
  Future<Either<Failure, firebase_auth.UserCredential>> authWithGoogle();
  Future<Either<Failure, firebase_auth.User>> login(
      String email, String password);
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, firebase_auth.User>> getAuthenticatedUser();
  Future<Either<Failure, UserModel>> getUserData(String uid);
  Future<Either<Failure, Unit>> resetPassword(String email);
  Future<Either<Failure, Unit>> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  });
  Future<Either<Failure, UserModel>> verifyOrCreateGoogleUser(
      firebase_auth.UserCredential credential);
}
