import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/cerrar_sesion_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helper.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LogoutUseCase logoutUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    logoutUseCase = LogoutUseCase(mockRepository);
  });

  test('deberia retornar Right(unit) cuando el cierre de sesión es exitoso',
      () async {
    when(() => mockRepository.logout()).thenAnswer(
      (_) async => const Right(unit),
    );

    final result = await logoutUseCase();

    expect(result, const Right(unit));
    verify(() => mockRepository.logout()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('deberia retornar UnexpectedFailure cuando ocurre un error inesperado',
      () async {
    when(() => mockRepository.logout()).thenAnswer(
      (_) async => const Left(UnexpectedFailure()),
    );

    final result = await logoutUseCase();

    expect(result, const Left(UnexpectedFailure()));
    verify(() => mockRepository.logout()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
