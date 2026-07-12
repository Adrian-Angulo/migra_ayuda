import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/router/app_router_mobile.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';
import 'package:migra_ayuda/features/userActivity/presentation/providers/activities_providers.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    try {
      final repository = ref.read(repositoryProvider);
      final user = await repository.getAuthenticatedUser();
      if (user == null) return null;
      // Obtener los datos completos del usuario
      final userData = await repository.getUserData(user.uid);
      return userData;
    } catch (e) {
      print('❌ Error al construir AuthNotifier: $e');
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(repositoryProvider);
      final activity = ref.read(activityProvider.notifier);

      // Ejecutar login
      final user = await repository.login(email, password);

      // Obtener datos completos del usuario
      final userData = await repository.getUserData(user.uid);

      state = AsyncValue.data(userData);
      activity.create(
          accion: ActivityActions.login(),
          );
      print('✅ Login exitoso: ${userData.name}');

      ref.read(routerMovilNotifierProvider).refresh();
    } on FirebaseAuthException catch (e, stack) {
      print('❌ Error de autenticación: ${e.message}');
      state = AsyncValue.error(_getAuthErrorMessage(e), stack);
      ref.read(routerMovilNotifierProvider).refresh();
    } catch (e, stack) {
      print('❌ Error inesperado en login: $e');
      state = AsyncValue.error('Error al iniciar sesión: $e', stack);
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
      print('✅ Logout exitoso');
    } catch (e, stack) {
      print('❌ Error en logout: $e');
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
      ref.read(activityProvider.notifier).create(
       
          accion: ActivityActions.login(),
          );
      ref.read(routerMovilNotifierProvider).refresh();
      debugPrint('Inicio de sesion con login');
    } on FirebaseAuthException catch (e, stack) {
      debugPrint('❌ Error de autenticación con Google: ${e.message}');
      state = AsyncValue.error(_getAuthErrorMessage(e), stack);
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
      state = AsyncValue.error(_getAuthErrorMessage(e), stack);
      ref.read(routerMovilNotifierProvider).refresh();
    } catch (e, stack) {
      print('❌ Error inesperado al completar perfil: $e');
      state = AsyncValue.error('Error al completar perfil: $e', stack);
      ref.read(routerMovilNotifierProvider).refresh();
    }
  }

  /// Obtener mensaje de error amigable
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe un usuario con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'email-already-in-use':
        return 'Este correo ya está en uso';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este correo usando otro método';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      default:
        return e.message ?? 'Error de autenticación';
    }
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
