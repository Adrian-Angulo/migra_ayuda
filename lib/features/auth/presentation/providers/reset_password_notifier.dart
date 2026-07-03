import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class ResetPasswordNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(repositoryProvider);
      await repository.resetPassword(email);

      state = const AsyncValue.data(null);
      print('✅ Correo de recuperación enviado a: $email');
    } on FirebaseAuthException catch (e, stack) {
      print('❌ Error al enviar correo de recuperación: ${e.message}');
      state = AsyncValue.error(_getAuthErrorMessage(e), stack);
    } catch (e, stack) {
      print('❌ Error inesperado al resetear contraseña: $e');
      state =
          AsyncValue.error('Error al enviar correo de recuperación: $e', stack);
    }
  }

  /// Obtener mensaje de error amigable
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe un usuario con este correo';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return e.message ?? 'Error al enviar correo de recuperación';
    }
  }
}

final resetPasswordProvider =
    AsyncNotifierProvider<ResetPasswordNotifier, void>(
        ResetPasswordNotifier.new);
