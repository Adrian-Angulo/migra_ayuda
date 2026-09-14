import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:migra_ayuda/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:migra_ayuda/features/auth/domain/entities/auth_user.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/auth/domain/usecases/auth_usecases.dart';


import 'package:migra_ayuda/features/users/presentation/providers/users_providers.dart';

// DataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(),
);

// Repository
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
      remoteDataSource: ref.read(authRemoteDataSourceProvider)),
);

// Backward-compatibility alias
final repositoryProvider = authRepositoryProvider;

// Use Cases
final loginWithEmailUseCaseProvider = Provider<LoginWithEmailUseCase>(
  (ref) => LoginWithEmailUseCase(ref.read(authRepositoryProvider)),
);

final registerWithEmailUseCaseProvider = Provider<RegisterWithEmailUseCase>(
  (ref) => RegisterWithEmailUseCase(
    ref.read(authRepositoryProvider),
    ref.read(userRepositoryProvider),
  ),
);

final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>(
  (ref) => LoginWithGoogleUseCase(
    ref.read(authRepositoryProvider),
    ref.read(userRepositoryProvider),
  ),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.read(authRepositoryProvider)),
);

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>(
  (ref) => ResetPasswordUseCase(ref.read(authRepositoryProvider)),
);

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>(
  (ref) => GetCurrentUserUseCase(ref.read(authRepositoryProvider)),
);

final watchAuthStateUseCaseProvider = Provider<WatchAuthStateUseCase>(
  (ref) => WatchAuthStateUseCase(ref.read(authRepositoryProvider)),
);

// Auth state stream provider
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.read(watchAuthStateUseCaseProvider)();
});
