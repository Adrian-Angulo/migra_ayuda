import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class ResetPasswordState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ResetPasswordState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ResetPasswordNotifier extends Notifier<ResetPasswordState> {
  @override
  ResetPasswordState build() {
    return ResetPasswordState();
  }

  Future<void> sendResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final resetPassword = ref.read(resetPasswordProvider);
      await resetPassword(email);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void reset() {
    state = ResetPasswordState();
  }
}

final resetPasswordNotifierProvider =
    NotifierProvider<ResetPasswordNotifier, ResetPasswordState>(
  ResetPasswordNotifier.new,
);
