import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/presentation/providers/users_providers.dart';

class AuthNotifier extends AsyncNotifier<Migrant?> {
  @override
  Future<Migrant?> build() async {
    try {
      final getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
      final getUserProfileUseCase = ref.read(getUserProfileUseCaseProvider);

      final authResult = await getCurrentUserUseCase();
      return await authResult.fold(
        (failure) async {
          debugPrint('❌ Error al obtener usuario inicial: ${failure.message}');
          return null;
        },
        (authUser) async {
          if (authUser == null) return null;
          final userProfileResult = await getUserProfileUseCase(authUser.id);
          return userProfileResult.fold(
            (failure) => null,
            (userData) {
              if (!kIsWeb && userData != null) {
                Future.microtask(() {
                  ref.read(auditNotifierProvider.notifier).create(
                        accion: ActivityActions.login(),
                      );
                });
              }
              return userData;
            },
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Error al construir AuthNotifier: $e');
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    final loginUseCase = ref.read(loginWithEmailUseCaseProvider);
    final getUserProfileUseCase = ref.read(getUserProfileUseCaseProvider);
    final activity = ref.read(auditNotifierProvider.notifier);

    // 1. Autenticar credenciales
    final loginResult = await loginUseCase(email, password);

    await loginResult.fold(
      (failure) async {
        debugPrint('❌ Error de autenticación: ${failure.message}');
        state = AsyncValue.error(failure.code ?? failure.message, StackTrace.current);
      },
      (authUser) async {
        // 2. Obtener datos completos del perfil de usuario
        final profileResult = await getUserProfileUseCase(authUser.id);

        profileResult.fold(
          (failure) {
            debugPrint('❌ Error al obtener perfil: ${failure.message}');
            state = AsyncValue.error(failure.message, StackTrace.current);
          },
          (userData) {
            state = AsyncValue.data(userData);
            debugPrint('✅ Login exitoso: ${userData?.name ?? authUser.email}');

            if (!kIsWeb) {
              activity.create(
                accion: ActivityActions.login(),
              );
            }
          },
        );
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    final logoutUseCase = ref.read(logoutUseCaseProvider);
    final result = await logoutUseCase();

    result.fold(
      (failure) {
        debugPrint('❌ Error en logout: ${failure.message}');
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        state = const AsyncValue.data(null);
        debugPrint('✅ Logout exitoso');
      },
    );
  }

  Future<void> authWithGoogle() async {
    state = const AsyncValue.loading();

    final loginWithGoogleUseCase = ref.read(loginWithGoogleUseCaseProvider);

    // Autenticar y obtener/crear perfil de usuario vía Caso de Uso
    final result = await loginWithGoogleUseCase();

    result.fold(
      (failure) {
        debugPrint('❌ Error de autenticación con Google: ${failure.message}');
        state = AsyncValue.error(failure.code ?? failure.message, StackTrace.current);
      },
      (userData) {
        state = AsyncValue.data(userData);
        if (!kIsWeb) {
          ref.read(auditNotifierProvider.notifier).create(
                accion: ActivityActions.loginGoogle(),
              );
        }
        debugPrint('✅ Inicio de sesión con Google exitoso');
      },
    );
  }

  Future<void> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    state = const AsyncValue.loading();

    final getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    final completeProfileUseCase = ref.read(completeProfileUseCaseProvider);
    final getUserProfileUseCase = ref.read(getUserProfileUseCaseProvider);

    final authResult = await getCurrentUserUseCase();

    await authResult.fold(
      (failure) async {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (authUser) async {
        if (authUser == null) {
          state = AsyncValue.error('Usuario no autenticado', StackTrace.current);
          return;
        }

        // Completar perfil en Users
        final completeResult = await completeProfileUseCase(
          id: authUser.id,
          originCountry: originCountry,
          destinationCountry: destinationCountry,
          age: age,
        );

        await completeResult.fold(
          (failure) async {
            debugPrint('❌ Error al completar perfil: ${failure.message}');
            state = AsyncValue.error(failure.message, StackTrace.current);
          },
          (_) async {
            // Obtener usuario actualizado
            final profileResult = await getUserProfileUseCase(authUser.id);
            profileResult.fold(
              (failure) {
                state = AsyncValue.error(failure.message, StackTrace.current);
              },
              (userData) {
                state = AsyncValue.data(userData);
              },
            );
          },
        );
      },
    );
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, Migrant?>(AuthNotifier.new);
