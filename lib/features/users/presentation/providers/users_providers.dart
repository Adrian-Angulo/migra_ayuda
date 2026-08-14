import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/users/data/repository/user_repository_impl.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(),
);

final getAllUsersProvider = StreamProvider<List<Migrant>>(
  (ref) {
    final repo = ref.read(userRepositoryProvider);
    return repo.getAllUsers();
  },
);
