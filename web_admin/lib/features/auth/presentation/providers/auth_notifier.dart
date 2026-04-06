import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda_administracion/features/auth/domain/entities/admin_entity.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/providers/providers.dart';

class AuthNotifier extends AsyncNotifier<AdminEntity?> {
  @override
  Future<AdminEntity?> build() async {
    final result = await ref.read(getAuthenticatedUserProvider).call();
    return result.fold((failure) => null, (user) => user);
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
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AdminEntity?>(
  AuthNotifier.new,
);
