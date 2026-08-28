import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/router/app_router_mobile.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    try {
      final repository = ref.read(repositoryProvider);
      final user = await repository.getAuthenticatedUser();
      if (user == null) return null;
      // Obtener los datos completos del usuario
      final userData = await repository.getUserData(user.uid);
      if (!kIsWeb) {
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
      final repository = ref.read(repositoryProvider);
      final activity = ref.read(auditNotifierProvider.notifier);

      // Ejecutar login
      final user = await repository.login(email, password);

      // Obtener datos completos del usuario
      final userData = await repository.getUserData(user.uid);

      state = AsyncValue.data(userData);

      debugPrint('✅ Login exitoso: ${userData.name}');

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
      final repository = ref.read(repositoryProvider);
      await repository.logout();

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
      final repository = ref.read(repositoryProvider);

      // Autenticar con Google
      final credential = await repository.authWithGoogle();

      // Verificar o crear usuario en Firestore
      final userData = await repository.verifyOrCreateGoogleUser(credential);

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
      final repository = ref.read(repositoryProvider);

      // Completar perfil
      await repository.completeProfile(
        originCountry: originCountry,
        destinationCountry: destinationCountry,
        age: age,
      );

      // Obtener usuario actualizado
      final user = await repository.getAuthenticatedUser();
      if (user != null) {
        final userData = await repository.getUserData(user.uid);
        state = AsyncValue.data(userData);
        ref.read(routerMovilNotifierProvider).refresh();
      }
    } on FirebaseAuthException catch (e, stack) {
      print('❌ Error al completar perfil: ${e.message}');
      state = AsyncValue.error(e.code, stack);
      ref.read(routerMovilNotifierProvider).refresh();
    } catch (e, stack) {
      print('❌ Error inesperado al completar perfil: $e');
      state = AsyncValue.error('Error al completar perfil: $e', stack);
      ref.read(routerMovilNotifierProvider).refresh();
    }
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
