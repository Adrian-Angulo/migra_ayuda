import 'package:migra_ayuda/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('onboarding_completed') ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (e) {
      throw Exception('No se pudo guardar el estado del onboarding: $e');
    }
  }
}
