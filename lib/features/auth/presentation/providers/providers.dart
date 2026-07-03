import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

/// Provider del repositorio de autenticación
///
/// Este es el único provider necesario para acceder a todas las
/// funcionalidades de autenticación.
final repositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepositoryImpl());

/// Provider del stream de cambios de estado de autenticación
///
/// Este provider observa en tiempo real los cambios de sesión del usuario
/// (login, logout, cambios en Firestore, etc.)
final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.read(repositoryProvider).authStateChanges();
});

class UsersNotifier extends AsyncNotifier<List<UserModel>> {
  @override
  Future<List<UserModel>> build() {
    return ref.read(repositoryProvider).getAllUsers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(repositoryProvider).getAllUsers(),
    );
  }
}

final usersNotifierProvider =
    AsyncNotifierProvider.autoDispose<UsersNotifier, List<UserModel>>(
        UsersNotifier.new);
