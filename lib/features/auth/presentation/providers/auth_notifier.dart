import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    return await ref.read(getAuthenticatedUserProvider).call();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        await ref.read(loginProvider).call(email, password);
        return ref.read(getAuthenticatedUserProvider).call();
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        await ref.read(logoutProvider).call();
        return ref.read(getAuthenticatedUserProvider).call();
      },
    );
  }

  Future<void> authWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        return await ref.read(authWithGoogleProvider).call();
      },
    );
  }

  Future<void> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        await ref.read(completeProfileProvider).call(
              originCountry: originCountry,
              destinationCountry: destinationCountry,
              age: age,
            );
        return ref.read(getAuthenticatedUserProvider).call();
      },
    );
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
