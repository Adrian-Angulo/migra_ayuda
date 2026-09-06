import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/users/data/datasource/firebase_datasource.dart';
import 'package:migra_ayuda/features/users/data/repository/user_repository_impl.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';
import 'package:migra_ayuda/features/users/domain/usecases/complete_profile_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/create_user_profile_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/get_all_users_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/get_user_profile_usecase.dart';

final usersDataSourceProvider = Provider<FirebaseUsersDatasource>(
  (ref) => FirebaseUsersDatasource(),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(firebase: ref.read(usersDataSourceProvider)),
);

// Use Cases Providers
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>(
  (ref) => GetUserProfileUseCase(ref.read(userRepositoryProvider)),
);

final createUserProfileUseCaseProvider = Provider<CreateUserProfileUseCase>(
  (ref) => CreateUserProfileUseCase(ref.read(userRepositoryProvider)),
);

final completeProfileUseCaseProvider = Provider<CompleteProfileUseCase>(
  (ref) => CompleteProfileUseCase(ref.read(userRepositoryProvider)),
);

final getAllUsersUseCaseProvider = Provider<GetAllUsersUseCase>(
  (ref) => GetAllUsersUseCase(ref.read(userRepositoryProvider)),
);

// Stream de usuarios
final getAllUsersProvider = StreamProvider<List<Migrant>>(
  (ref) {
    final useCase = ref.read(getAllUsersUseCaseProvider);
    return useCase();
  },
);

