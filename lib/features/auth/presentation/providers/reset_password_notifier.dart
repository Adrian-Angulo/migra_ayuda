import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class ResetPasswordNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<dynamic> build() {}

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        await ref.read(resetPasswordProviderUseCase).call(email);
      },
    );
  }
}

final resetPasswordProvider =
    AsyncNotifierProvider<ResetPasswordNotifier, void>(
        ResetPasswordNotifier.new);
