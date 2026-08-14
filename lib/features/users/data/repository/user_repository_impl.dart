import 'package:migra_ayuda/features/users/data/datasource/firebase_datasource.dart';
import 'package:migra_ayuda/features/users/data/mapper/user_migrant_mapper.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseUsersDatasource _firebase = FirebaseUsersDatasource();

  @override
  Stream<List<Migrant>> getAllUsers() {
    return _firebase.getAll().map((models) =>
        models.map((model) => UserMigrantMapper.fromModel(model)).toList());
  }
}
