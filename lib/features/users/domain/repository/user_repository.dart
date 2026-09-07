
import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';

abstract class UserRepository {
  Future<Either<Failure, Migrant?>> getUserById(String id);
  Future<Either<Failure, void>> createUser(Migrant user);
  Future<Either<Failure, void>> completeProfile({
    required String id,
    required String originCountry,
    required String destinationCountry,
    required int age,
  });
  Stream<List<Migrant>> getAllUsers();
}

