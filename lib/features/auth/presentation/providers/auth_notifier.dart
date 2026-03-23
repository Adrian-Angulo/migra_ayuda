import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final AuthRepository _repository;

  @override
  FutureOr<UserModel?> build() {
    _repository = ref.read(authRepositoryProvider);
    //recibimos el usuario actual desde el repositorio
    return _repository.getUsuarioActual();
  }

  Future<void> login(String email, String password) async {
    final loginUser = ref.read(loginUserProvider);
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return await loginUser(email, password);
    });
  }

  Future<void> logout() async {
    final logout = ref.read(logoutProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await logout();
      return _repository.getUsuarioActual();
    });
  }


}
