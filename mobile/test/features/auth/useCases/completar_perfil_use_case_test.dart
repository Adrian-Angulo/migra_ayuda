import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/completar_perfil_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helper.dart';

void main() {
  late MockAuthRepository mockRepository;
  late CompleteProfileUseCase completeProfileUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    completeProfileUseCase = CompleteProfileUseCase(mockRepository);
  });

  const testOriginCountry = 'México';
  const testDestinationCountry = 'España';
  const testAge = 30;

  test('deberia retornar Right(unit) cuando el perfil se completa exitosamente',
      () async {
    when(() => mockRepository.completeProfile(
          originCountry: testOriginCountry,
          destinationCountry: testDestinationCountry,
          age: testAge,
        )).thenAnswer(
      (_) async => const Right(unit),
    );

    final result = await completeProfileUseCase(
      originCountry: testOriginCountry,
      destinationCountry: testDestinationCountry,
      age: testAge,
    );

    expect(result, const Right(unit));
    verify(() => mockRepository.completeProfile(
          originCountry: testOriginCountry,
          destinationCountry: testDestinationCountry,
          age: testAge,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('deberia retornar UnexpectedFailure cuando ocurre un error inesperado',
      () async {
    when(() => mockRepository.completeProfile(
          originCountry: testOriginCountry,
          destinationCountry: testDestinationCountry,
          age: testAge,
        )).thenAnswer(
      (_) async => const Left(UnexpectedFailure()),
    );

    final result = await completeProfileUseCase(
      originCountry: testOriginCountry,
      destinationCountry: testDestinationCountry,
      age: testAge,
    );

    expect(result, const Left(UnexpectedFailure()));
    verify(() => mockRepository.completeProfile(
          originCountry: testOriginCountry,
          destinationCountry: testDestinationCountry,
          age: testAge,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('deberia retornar NetworkFailureAuth cuando hay error de conexión',
      () async {
    when(() => mockRepository.completeProfile(
          originCountry: testOriginCountry,
          destinationCountry: testDestinationCountry,
          age: testAge,
        )).thenAnswer(
      (_) async => const Left(NetworkFailureAuth()),
    );

    final result = await completeProfileUseCase(
      originCountry: testOriginCountry,
      destinationCountry: testDestinationCountry,
      age: testAge,
    );

    expect(result, const Left(NetworkFailureAuth()));
    verify(() => mockRepository.completeProfile(
          originCountry: testOriginCountry,
          destinationCountry: testDestinationCountry,
          age: testAge,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
