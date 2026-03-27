import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/registrar_usuario_use_case.dart';

final repositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);

final registrarUseCaseProvider = Provider<RegistrarUsuarioUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return RegistrarUsuarioUseCase(repo);
  },
);
