import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/domain/usecases/auth_usecases.dart';

import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class RegisterNotifier extends AsyncNotifier<bool?> {
  @override
  Future<bool?> build() async {
    return null;
  }

  Future<void> registerUser(RegisterUserParams params) async {
    state = const AsyncValue.loading();

    final registerUseCase = ref.read(registerWithEmailUseCaseProvider);
    final result = await registerUseCase(params);

    result.fold(
      (failure) {
        debugPrint('❌ Error al registrar: ${failure.message}');
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (authUser) {
        state = const AsyncValue.data(true);
        debugPrint('✅ Usuario registrado exitosamente: ${params.email}');
      },
    );
  }
}

final registerProvider =
    AsyncNotifierProvider<RegisterNotifier, bool?>(RegisterNotifier.new);


