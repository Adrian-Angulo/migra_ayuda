import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final result = await ref.read(getAuthenticatedUserProvider).call();
    return result.fold(
      (failure) => null,
      (user) => user,
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    final loginResult = await ref.read(loginProvider).call(email, password);

    loginResult.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      
      (_) async {
        final userResult = await ref.read(getAuthenticatedUserProvider).call();
        userResult.fold(
          (failure) =>
              state = AsyncValue.error(failure.message, StackTrace.current),
          (user) => state = AsyncValue.data(user),
        );
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    final result = await ref.read(logoutProvider).call();

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        state = const AsyncValue.data(null);
      },
    );
  }

  Future<void> authWithGoogle() async {
    state = const AsyncValue.loading();

    final result = await ref.read(authWithGoogleProvider).call();

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (user) {
        state = AsyncValue.data(user);
      },
    );
  }

  Future<void> completeProfile({
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    state = const AsyncValue.loading();

    final completeResult = await ref.read(completeProfileProvider).call(
          originCountry: originCountry,
          destinationCountry: destinationCountry,
          age: age,
        );

    completeResult.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) async {
        final userResult = await ref.read(getAuthenticatedUserProvider).call();
        userResult.fold(
          (failure) =>
              state = AsyncValue.error(failure.message, StackTrace.current),
          (user) => state = AsyncValue.data(user),
        );
      },
    );
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
