import 'package:migra_ayuda/core/errors/failure.dart';

abstract class OnboardingFailure extends Failure {
  const OnboardingFailure({required super.message, super.code});
}

class OnboardingStorageFailure extends OnboardingFailure {
  const OnboardingStorageFailure({
    super.message = 'Error al guardar el estado del onboarding',
    super.code = 'onboarding-storage-failed',
  });
}
class SetOnboardingFailure extends OnboardingFailure {
  const SetOnboardingFailure({
    super.message = 'Error al cargar estado de onboarding',
    super.code = 'onboarding-storage-failed',
  });
}

class GenericOnboardingFailure extends OnboardingFailure {
  const GenericOnboardingFailure({
    required super.message,
    super.code,
  });
}
