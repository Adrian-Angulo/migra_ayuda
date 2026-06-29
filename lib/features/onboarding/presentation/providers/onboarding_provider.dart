import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:migra_ayuda/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:migra_ayuda/features/onboarding/domain/repositories/onboarding_repository.dart';

// Repository Provider
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepositoryImpl(),
);

// Onboarding Provider
final onboardingProvider = AsyncNotifierProvider<OnboardingNotifier, bool>(
  () => OnboardingNotifier(),
);

// Onboarding Notifier
class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    final repo = ref.watch(onboardingRepositoryProvider);
    return await repo.hasCompletedOnboarding();
  }

  Future<void> completeOnboarding() async {
    state = const AsyncValue.loading();
    final repository = ref.watch(onboardingRepositoryProvider);
    try {
      await repository.completeOnboarding();
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
