import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/onboarding/domain/failures/onboarding_failures.dart';
import 'package:migra_ayuda/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:migra_ayuda/features/onboarding/domain/usecases/onboarding_usecases.dart';
import 'package:mocktail/mocktail.dart';


/// Mock del repositorio de onboarding
class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockOnboardingRepository mockOnboardingRepository;

  setUp(() {
    mockOnboardingRepository = MockOnboardingRepository();
  });

  group('HasCompletedOnboardingUseCase', () {
    late HasCompletedOnboardingUseCase useCase;

    setUp(() {
      useCase = HasCompletedOnboardingUseCase(mockOnboardingRepository);
    });

    test(
      'éxito: debería retornar Right(true) cuando se consulta el estado del onboarding exitosamente',
      () async {
        // Arrange (Preparar)
        when(() => mockOnboardingRepository.hasCompletedOnboarding())
            .thenAnswer((_) async => const Right(true));

        // Act (Actuar)
        final result = await useCase();

        // Assert (Verificar)
        expect(result, const Right(true));
        verify(() => mockOnboardingRepository.hasCompletedOnboarding()).called(1);
        verifyNoMoreInteractions(mockOnboardingRepository);
      },
    );

    test(
      'error: debería retornar Left(OnboardingStorageFailure) cuando ocurre un error al consultar el estado',
      () async {
        // Arrange (Preparar)
        when(() => mockOnboardingRepository.hasCompletedOnboarding())
            .thenAnswer((_) async => const Left(OnboardingStorageFailure()));

        // Act (Actuar)
        final result = await useCase();

        // Assert (Verificar)
        expect(result, const Left(OnboardingStorageFailure()));
        verify(() => mockOnboardingRepository.hasCompletedOnboarding()).called(1);
        verifyNoMoreInteractions(mockOnboardingRepository);
      },
    );
  });

  group('CompleteOnboardingUseCase', () {
    late CompleteOnboardingUseCase useCase;

    setUp(() {
      useCase = CompleteOnboardingUseCase(mockOnboardingRepository);
    });

    test(
      'éxito: debería completar el onboarding exitosamente y retornar Right(null)',
      () async {
        // Arrange (Preparar)
        when(() => mockOnboardingRepository.completeOnboarding())
            .thenAnswer((_) async => const Right(null));

        // Act (Actuar)
        final result = await useCase();

        // Assert (Verificar)
        expect(result, const Right(null));
        verify(() => mockOnboardingRepository.completeOnboarding()).called(1);
        verifyNoMoreInteractions(mockOnboardingRepository);
      },
    );

    test(
      'error: debería retornar Left(OnboardingStorageFailure) cuando ocurre un error al marcar como completado',
      () async {
        // Arrange (Preparar)
        when(() => mockOnboardingRepository.completeOnboarding())
            .thenAnswer((_) async => const Left(OnboardingStorageFailure()));

        // Act (Actuar)
        final result = await useCase();

        // Assert (Verificar)
        expect(result, const Left(OnboardingStorageFailure()));
        verify(() => mockOnboardingRepository.completeOnboarding()).called(1);
        verifyNoMoreInteractions(mockOnboardingRepository);
      },
    );
  });
}
