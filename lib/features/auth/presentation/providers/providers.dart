import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/auth_con_google_use_case.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/cerrar_sesion_use_case.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/completar_perfil_use_case.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/iniciar_sesion_use_case.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/registrar_usuario_use_case.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/restablecer_contrasena_use_case.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/usuario_autenticado_use_case.dart';

final repositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepositoryImpl());

final registerUserUseCaseProvider = Provider<RegisterUserUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return RegisterUserUseCase(repo);
  },
);

final getAuthenticatedUserProvider = Provider<GetAuthenticatedUserUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return GetAuthenticatedUserUseCase(repo);
  },
);

final loginProvider = Provider<LoginUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return LoginUseCase(repo);
  },
);

final logoutProvider = Provider<LogoutUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return LogoutUseCase(repo);
  },
);

final authWithGoogleProvider = Provider<AuthWithGoogleUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return AuthWithGoogleUseCase(repo);
  },
);

final completeProfileProvider = Provider<CompleteProfileUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return CompleteProfileUseCase(repo);
  },
);

final resetPasswordProviderUseCase = Provider<ResetPasswordUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return ResetPasswordUseCase(repo);
  },
);

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.read(repositoryProvider).authStateChanges();
});
