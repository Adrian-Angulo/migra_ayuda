import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda_administracion/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/useCases/cerrar_sesion_use_case.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/useCases/iniciar_sesion_use_case.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/useCases/restablecer_contrasena_use_case.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/useCases/usuario_autenticado_use_case.dart';

final repositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

final getAuthenticatedUserProvider = Provider<GetAuthenticatedUserUseCase>((
  ref,
) {
  final repo = ref.read(repositoryProvider);
  return GetAuthenticatedUserUseCase(repo);
});

final loginProvider = Provider<LoginUseCase>((ref) {
  final repo = ref.read(repositoryProvider);
  return LoginUseCase(repo);
});

final logoutProvider = Provider<LogoutUseCase>((ref) {
  final repo = ref.read(repositoryProvider);
  return LogoutUseCase(repo);
});

final resetPasswordProviderUseCase = Provider<ResetPasswordUseCase>((ref) {
  final repo = ref.read(repositoryProvider);
  return ResetPasswordUseCase(repo);
});
