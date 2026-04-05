import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/providers/providers.dart';

class ResetPasswordNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<dynamic> build() {}

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();

    final result = await ref.read(resetPasswordProviderUseCase).call(email);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        state = const AsyncValue.data(null);
      },
    );
  }
}

final resetPasswordProvider =
    AsyncNotifierProvider<ResetPasswordNotifier, void>(
      ResetPasswordNotifier.new,
    );
