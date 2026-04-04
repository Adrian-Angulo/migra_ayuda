import 'package:riverpod/riverpod.dart';
import 'package:migra_ayuda/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:migra_ayuda/features/onboarding/domain/repositories/onboarding_repository.dart';

// Repository Provider
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepositoryImpl(),
);

// Onboarding Notifier
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadOnboardingStatus();
    return false;
  }

  Future<void> _loadOnboardingStatus() async {
    final repository = ref.read(onboardingRepositoryProvider);
    final hasCompleted = await repository.hasCompletedOnboarding();
    state = hasCompleted;
  }

  Future<void> completeOnboarding() async {
    final repository = ref.read(onboardingRepositoryProvider);
    await repository.completeOnboarding();
    state = true;
  }
}

// Onboarding Provider
final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(
  () => OnboardingNotifier(),
);
