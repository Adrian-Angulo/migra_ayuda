import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository2.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final AuthRepository2 _repository2;

  @override
  FutureOr<UserModel?> build() {
    _repository2 = ref.read(authRepositoryProvider);
    //recibimos el usuario actual desde el repositorio
    return _repository2.getUsuarioActual();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _repository2.login(email, password);
      return _repository2.getUsuarioActual();
    });
  }
}
