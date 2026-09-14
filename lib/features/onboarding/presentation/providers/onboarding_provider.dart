import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/router/app_router_mobile.dart';
import 'package:migra_ayuda/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:migra_ayuda/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:migra_ayuda/features/onboarding/domain/usecases/onboarding_usecases.dart';

// Repository Provider
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepositoryImpl(),
);

// Use Case Providers
final hasCompletedOnboardingUseCaseProvider =
    Provider<HasCompletedOnboardingUseCase>((ref) {
  return HasCompletedOnboardingUseCase(ref.read(onboardingRepositoryProvider));
});

final completeOnboardingUseCaseProvider =
    Provider<CompleteOnboardingUseCase>((ref) {
  return CompleteOnboardingUseCase(ref.read(onboardingRepositoryProvider));
});

// Onboarding Provider
final onboardingProvider = AsyncNotifierProvider<OnboardingNotifier, bool>(
  () => OnboardingNotifier(),
);

// Onboarding Notifier
class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    final hasCompletedUseCase = ref.watch(hasCompletedOnboardingUseCaseProvider);
    final result = await hasCompletedUseCase();
    return result.fold(
      (failure) => false,
      (hasCompleted) => hasCompleted,
    );
  }

  Future<void> completeOnboarding() async {
    state = const AsyncValue.loading();
    final completeUseCase = ref.read(completeOnboardingUseCaseProvider);
    final result = await completeUseCase();

    result.fold(
      (failure) {
        state = AsyncValue.error(
          failure.message,
          StackTrace.current,
        );
        ref.read(routerMovilNotifierProvider).refresh();
      },
      (_) {
        state = const AsyncValue.data(true);
        ref.read(routerMovilNotifierProvider).refresh();
      },
    );
  }
}
