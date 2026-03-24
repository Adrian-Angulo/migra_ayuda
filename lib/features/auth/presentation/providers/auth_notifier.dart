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
      await loginUser(email, password);
      return _repository.getUsuarioActual();
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

  Future<void> register(
      {required String name,
      required String lasname,
      required String email,
      required String password,
      required String originCountry,
      required String destinationCountry,
      required int age}) async {
    final register = ref.read(registerProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await register(
          name: name,
          lasname: lasname,
          email: email,
          password: password,
          originCountry: originCountry,
          destinationCountry: destinationCountry,
          age: age);
      return _repository.getUsuarioActual();
    });
  }

  Future<bool> authWithGoogle() async {
    final authGoogle = ref.read(authGoogleProvider);
    state = const AsyncValue.loading();

    try {
      final result = await authGoogle();
      state = await AsyncValue.guard(() => _repository.getUsuarioActual());
      return result.isFirstTime;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> completeGoogleProfile({
    required String userId,
    required String originCountry,
    required String destinationCountry,
    required int age,
  }) async {
    final completeProfile = ref.read(completeGoogleProfileProvider);
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await completeProfile(
        userId: userId,
        originCountry: originCountry,
        destinationCountry: destinationCountry,
        age: age,
      );
      return _repository.getUsuarioActual();
    });
  }
}
