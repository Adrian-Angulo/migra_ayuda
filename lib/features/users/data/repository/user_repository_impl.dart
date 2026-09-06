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
  Future<Migrant?> getUserById(String id) async {
    final model = await _firebase.getById(id);
    if (model == null) return null;
    return UserMigrantMapper.fromModel(model);
  }

  @override
  Future<void> createUser(Migrant user) async {
    final model = UserMigrantMapper.toModel(user);
    await _firebase.setWithId(user.id, model);
  }

  @override
  Future<void> completeProfile({
    required String id,
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    await _firebase.updateFields(id, {
      'originCountry': originCountry,
      'destinationCountry': destinationCountry,
      'age': age.toString(),
      'profileComplete': true,
    });
  }
}

