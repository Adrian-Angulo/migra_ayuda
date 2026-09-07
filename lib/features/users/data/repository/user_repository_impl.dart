import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/users/data/datasource/firebase_datasource.dart';
import 'package:migra_ayuda/features/users/data/mapper/user_migrant_mapper.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseUsersDatasource _firebase;

  UserRepositoryImpl({FirebaseUsersDatasource? firebase})
      : _firebase = firebase ?? FirebaseUsersDatasource();

  @override
  Stream<List<Migrant>> getAllUsers() {
    return _firebase.getAll().map((models) =>
        models.map((model) => UserMigrantMapper.fromModel(model)).toList());
  }

  @override
  Future<Either<Failure, Migrant?>> getUserById(String id) async {
    try {
      final model = await _firebase.getById(id);
      if (model == null) return const Right(null);
      return Right(UserMigrantMapper.fromModel(model));
    } on FirebaseException catch (e) {
      return Left(GenericUserFailure(
        message: e.message ?? 'Error al obtener usuario',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createUser(Migrant user) async {
    try {
      final model = UserMigrantMapper.toModel(user);
      await _firebase.setWithId(user.id, model);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(UserProfileCreationFailedFailure(
        message: e.message ?? 'Error al crear el perfil de usuario',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeProfile({
    required String id,
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    try {
      await _firebase.updateFields(id, {
        'originCountry': originCountry,
        'destinationCountry': destinationCountry,
        'age': age.toString(),
        'profileComplete': true,
      });
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(UserProfileUpdateFailedFailure(
        message: e.message ?? 'Error al actualizar el perfil de usuario',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

