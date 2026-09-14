import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, bool>> hasCompletedOnboarding();
  Future<Either<Failure, void>> completeOnboarding();
}
