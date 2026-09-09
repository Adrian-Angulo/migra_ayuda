import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/login_rate_limiter_provider.dart';

void main() {
  group('LoginRateLimiterNotifier Tests', () {
    test('Inicia con 0 intentos y no bloqueado', () {
      final container = ProviderContainer();
      final state = container.read(loginRateLimiterProvider);

      expect(state.failedAttempts, 0);
      expect(state.cooldownSeconds, 0);
      expect(state.isLocked, isFalse);
    });

    test('Incrementa intentos fallidos sin bloquear si es menor a 5', () {
      final container = ProviderContainer();
      final notifier = container.read(loginRateLimiterProvider.notifier);

      notifier.recordFailedAttempt();
      expect(container.read(loginRateLimiterProvider).failedAttempts, 1);
      expect(container.read(loginRateLimiterProvider).isLocked, isFalse);

      notifier.recordFailedAttempt();
      notifier.recordFailedAttempt();
      notifier.recordFailedAttempt();
      expect(container.read(loginRateLimiterProvider).failedAttempts, 4);
      expect(container.read(loginRateLimiterProvider).isLocked, isFalse);
    });

    test('Bloquea la UI por 30 segundos al alcanzar el 5to intento fallido', () {
      final container = ProviderContainer();
      final notifier = container.read(loginRateLimiterProvider.notifier);

      for (int i = 0; i < 5; i++) {
        notifier.recordFailedAttempt();
      }

      final state = container.read(loginRateLimiterProvider);
      expect(state.failedAttempts, 5);
      expect(state.isLocked, isTrue);
      expect(state.cooldownSeconds, 30);
    });

    test('Restablece los intentos y cancela el bloqueo al llamar reset()', () {
      final container = ProviderContainer();
      final notifier = container.read(loginRateLimiterProvider.notifier);

      for (int i = 0; i < 5; i++) {
        notifier.recordFailedAttempt();
      }

      expect(container.read(loginRateLimiterProvider).isLocked, isTrue);

      notifier.reset();
      final resetState = container.read(loginRateLimiterProvider);
      expect(resetState.failedAttempts, 0);
      expect(resetState.isLocked, isFalse);
      expect(resetState.cooldownSeconds, 0);
    });
  });
}
