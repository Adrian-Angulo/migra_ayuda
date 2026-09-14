import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/onboarding/domain/repositories/onboarding_repository.dart';

class HasCompletedOnboardingUseCase {
  final OnboardingRepository _repository;

  HasCompletedOnboardingUseCase(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.hasCompletedOnboarding();
  }
}

class CompleteOnboardingUseCase {
  final OnboardingRepository _repository;

  CompleteOnboardingUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.completeOnboarding();
  }
}
