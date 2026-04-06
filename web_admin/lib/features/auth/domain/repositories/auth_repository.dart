import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:migra_ayuda_administracion/core/errors/failures.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/entities/admin_entity.dart';

abstract class AuthRepository {

  Future<Either<Failure, User>> login(
      String email, String password);
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, User>> getAuthenticatedUser();
  Future<Either<Failure, AdminEntity>> getUserData(String uid);
  Future<Either<Failure, Unit>> resetPassword(String email);

}
