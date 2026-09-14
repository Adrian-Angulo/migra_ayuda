import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado del limitador de tasa de intentos de inicio de sesión.
class RateLimiterState {
  final int failedAttempts;
  final int cooldownSeconds;
  final bool isLocked;

  const RateLimiterState({
    this.failedAttempts = 0,
    this.cooldownSeconds = 0,
    this.isLocked = false,
  });

  RateLimiterState copyWith({
    int? failedAttempts,
    int? cooldownSeconds,
    bool? isLocked,
  }) {
    return RateLimiterState(
      failedAttempts: failedAttempts ?? this.failedAttempts,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

/// Notificador que gestiona el bloqueo temporal por intentos fallidos de login.
class LoginRateLimiterNotifier extends Notifier<RateLimiterState> {
  Timer? _timer;

  static const int maxAllowedAttempts = 5;
  static const int defaultCooldownDuration = 120;

  @override
  RateLimiterState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const RateLimiterState();
  }

  /// Registra un intento fallido y activa el temporizador si se alcanza el límite.
  void recordFailedAttempt() {
    final nextAttempts = state.failedAttempts + 1;
    if (nextAttempts >= maxAllowedAttempts) {
      _startCooldown(defaultCooldownDuration);
    } else {
      state = state.copyWith(failedAttempts: nextAttempts);
    }
  }

  /// Restablece los intentos y cancela cualquier temporizador activo.
  void reset() {
    _timer?.cancel();
    state = const RateLimiterState();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    state = RateLimiterState(
      failedAttempts: maxAllowedAttempts,
      cooldownSeconds: seconds,
      isLocked: true,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.cooldownSeconds > 1) {
        state = state.copyWith(
          cooldownSeconds: state.cooldownSeconds - 1,
          isLocked: true,
        );
      } else {
        timer.cancel();
        reset();
      }
    });
  }
}

/// Provider global para el control de tasa de intentos de login.
final loginRateLimiterProvider =
    NotifierProvider<LoginRateLimiterNotifier, RateLimiterState>(
  LoginRateLimiterNotifier.new,
);
