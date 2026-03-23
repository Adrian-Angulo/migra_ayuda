import 'package:migra_ayuda/core/models/user_model.dart';

class AuthState {
  final bool loading;
  final String? error;
  final UserModel? user;

  AuthState({
    this.loading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({bool? loading, String? error, UserModel? user}) {
    return AuthState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}
