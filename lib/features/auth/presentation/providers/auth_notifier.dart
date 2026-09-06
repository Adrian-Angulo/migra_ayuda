import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/router/app_router_mobile.dart';
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

      final authUser = await getCurrentUserUseCase();
      if (authUser == null) return null;

      // Obtener el perfil completo del usuario desde users
      final userData = await getUserProfileUseCase(authUser.id);
      if (!kIsWeb && userData != null) {
        Future.microtask(() {
          ref.read(auditNotifierProvider.notifier).create(
                accion: ActivityActions.login(),
              );
        });
      }
      return userData;
    } catch (e) {
      debugPrint('❌ Error al construir AuthNotifier: $e');
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final loginUseCase = ref.read(loginWithEmailUseCaseProvider);
      final getUserProfileUseCase = ref.read(getUserProfileUseCaseProvider);
      final activity = ref.read(auditNotifierProvider.notifier);

      // 1. Autenticar credenciales
      final authUser = await loginUseCase(email, password);

      // 2. Obtener datos completos del perfil de usuario
      final userData = await getUserProfileUseCase(authUser.id);

      state = AsyncValue.data(userData);

      debugPrint('✅ Login exitoso: ${userData?.name ?? authUser.email}');

      ref.read(routerMovilNotifierProvider).refresh();
      if (!kIsWeb) {
        activity.create(
          accion: ActivityActions.login(),
        );
      }
    } on FirebaseAuthException catch (e, stack) {
      debugPrint('❌ Error de autenticación: ${e.message}');
      state = AsyncValue.error(e.code, stack);
      ref.read(routerMovilNotifierProvider).refresh();
    } catch (e, stack) {
      debugPrint('❌ Error inesperado en login: $e');
      final errorMsg = e.toString().contains('email-not-verified') ||
              e.toString().contains('email_not_verified')
          ? 'email-not-verified'
          : 'Error al iniciar sesión: $e';
      state = AsyncValue.error(errorMsg, stack);
      ref.read(routerMovilNotifierProvider).refresh();
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      await logoutUseCase();

      state = const AsyncValue.data(null);
      ref.read(routerMovilNotifierProvider).refresh();
      debugPrint('✅ Logout exitoso');
    } catch (e, stack) {
      debugPrint('❌ Error en logout: $e');
      state = AsyncValue.error('Error al cerrar sesión: $e', stack);
      ref.read(routerMovilNotifierProvider).refresh();
    }
  }

  Future<void> authWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final loginWithGoogleUseCase = ref.read(loginWithGoogleUseCaseProvider);

      // Autenticar y obtener/crear perfil de usuario vía Caso de Uso
      final userData = await loginWithGoogleUseCase();

      state = AsyncValue.data(userData);
      if (!kIsWeb) {
        ref.read(auditNotifierProvider.notifier).create(
              accion: ActivityActions.loginGoogle(),
            );
      }
      ref.read(routerMovilNotifierProvider).refresh();
      debugPrint('Inicio de sesión con Google exitoso');
    } on FirebaseAuthException catch (e, stack) {

      debugPrint('❌ Error de autenticación con Google: ${e.message}');
      state = AsyncValue.error(e.code, stack);
      ref.read(routerMovilNotifierProvider).refresh();
    } catch (e, stack) {
      debugPrint('❌ Error inesperado en authWithGoogle: $e');
      state = AsyncValue.error('Error al autenticar con Google: $e', stack);
      ref.read(routerMovilNotifierProvider).refresh();
    }
  }

  Future<void> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    state = const AsyncValue.loading();

    try {
      final getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
      final completeProfileUseCase = ref.read(completeProfileUseCaseProvider);
      final getUserProfileUseCase = ref.read(getUserProfileUseCaseProvider);

      final authUser = await getCurrentUserUseCase();
      if (authUser == null) {
        throw Exception('user_not_found');
      }

      // Completar perfil en Users
      await completeProfileUseCase(
        id: authUser.id,
        originCountry: originCountry,
        destinationCountry: destinationCountry,
        age: age,
      );

      // Obtener usuario actualizado
      final userData = await getUserProfileUseCase(authUser.id);
      state = AsyncValue.data(userData);
      ref.read(routerMovilNotifierProvider).refresh();
    } on FirebaseAuthException catch (e, stack) {
      debugPrint('❌ Error al completar perfil: ${e.message}');
      state = AsyncValue.error(e.code, stack);
      ref.read(routerMovilNotifierProvider).refresh();
    } catch (e, stack) {
      debugPrint('❌ Error inesperado al completar perfil: $e');
      state = AsyncValue.error('Error al completar perfil: $e', stack);
      ref.read(routerMovilNotifierProvider).refresh();
    }
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, Migrant?>(AuthNotifier.new);

