import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/onboarding/domain/failures/onboarding_failures.dart';
import 'package:migra_ayuda/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  Future<Either<Failure, bool>> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompleted = prefs.getBool('onboarding_completed') ?? false;
      return Right(hasCompleted);
    } catch (_) {
      return const Left(SetOnboardingFailure());
    }
  }

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      return const Right(null);
    } catch (_) {
      return const Left(OnboardingStorageFailure());
    }
  }
}
