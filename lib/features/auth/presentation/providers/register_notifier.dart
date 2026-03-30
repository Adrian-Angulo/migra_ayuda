import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class RegisterNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> registerUser(UserModel user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        await ref.read(registerUserUseCaseProvider).call(user);
      },
    );
  }
}

final registerProvider =
    AsyncNotifierProvider<RegisterNotifier, void>(RegisterNotifier.new);
