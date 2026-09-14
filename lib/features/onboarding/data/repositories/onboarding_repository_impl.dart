import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// lib/features/onboarding/data/repositories/onboarding_repository_impl.dart
class OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  Future<Either<Failure, bool>> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompleted = prefs.getBool('onboarding_completed') ?? false;
      return Right(hasCompleted);
    } catch (e) {
      return const Left(GenericOnboardingFailure(
        message: 'Error al verificar el estado del onboarding: ',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      return const Right(null);
    } catch (e) {
      return const Left(OnboardingStorageFailure(
        message: 'No se pudo guardar el estado del onboarding',
      ));
    }
  }
}
