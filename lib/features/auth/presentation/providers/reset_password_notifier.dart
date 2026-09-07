import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class ResetPasswordNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();

    final resetPasswordUseCase = ref.read(resetPasswordUseCaseProvider);
    final result = await resetPasswordUseCase(email);

    result.fold(
      (failure) {
        debugPrint('❌ Error al enviar correo de recuperación: ${failure.message}');
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        state = const AsyncValue.data(null);
        debugPrint('✅ Correo de recuperación enviado a: $email');
      },
    );
  }
}

final resetPasswordProvider =
    AsyncNotifierProvider<ResetPasswordNotifier, void>(
        ResetPasswordNotifier.new);

