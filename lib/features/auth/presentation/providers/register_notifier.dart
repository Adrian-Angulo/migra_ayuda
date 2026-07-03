import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class RegisterNotifier extends AsyncNotifier<bool?> {
  @override
  Future<bool?> build() async {
    return null;
  }

  void registerUser(UserModel user) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(repositoryProvider);
      await repository.registerUser(user);

      state = const AsyncValue.data(true);
      print('✅ Usuario registrado exitosamente: ${user.email}');
    } on FirebaseAuthException catch (e, stack) {
      print('❌ Error de autenticación al registrar: ${e.message}');
      state = AsyncValue.error(_getAuthErrorMessage(e), stack);
    } catch (e, stack) {
      print('❌ Error inesperado al registrar: $e');
      state = AsyncValue.error('Error al registrar usuario: $e', stack);
    }
  }

  /// Obtener mensaje de error amigable
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      default:
        return e.message ?? 'Error al registrar usuario';
    }
  }
}

final registerProvider =
    AsyncNotifierProvider<RegisterNotifier, bool?>(RegisterNotifier.new);
