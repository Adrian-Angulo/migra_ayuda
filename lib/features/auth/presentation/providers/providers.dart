import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/cerrar_sesion_use_case.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/iniciar_sesion_use_case.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/registrar_usuario_use_case.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/usuario_autenticado_use_case.dart';

final repositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);

final registrarUseCaseProvider = Provider<RegistrarUsuarioUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return RegistrarUsuarioUseCase(repo);
  },
);

final usuarioAutenticadoProvider = Provider<UsuarioAutenticadoUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return UsuarioAutenticadoUseCase(repo);
  },
);

final iniciarSesionProvider = Provider<IniciarSesionUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return IniciarSesionUseCase(repo);
  },
);

final cerrarSesionProvider = Provider<CerrarSesionUseCase>(
  (ref) {
    final repo = ref.read(repositoryProvider);
    return CerrarSesionUseCase(repo);
  },
);
