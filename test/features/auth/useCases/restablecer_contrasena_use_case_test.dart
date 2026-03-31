import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/restablecer_contrasena_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helper.dart';

void main() {
  late MockAuthRepository mockRepository;
  late ResetPasswordUseCase resetPasswordUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    resetPasswordUseCase = ResetPasswordUseCase(mockRepository);
  });

  const testEmail = 'test@example.com';

  test(
      'deberia retornar Right(unit) cuando el restablecimiento de contraseña es exitoso',
      () async {
    when(() => mockRepository.resetPassword(testEmail)).thenAnswer(
      (_) async => const Right(unit),
    );

    final result = await resetPasswordUseCase(testEmail);

    expect(result, const Right(unit));
    verify(() => mockRepository.resetPassword(testEmail)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('deberia retornar UserNotFoundFailure cuando el usuario no existe',
      () async {
    when(() => mockRepository.resetPassword(testEmail)).thenAnswer(
      (_) async => const Left(UserNotFoundFailure()),
    );

    final result = await resetPasswordUseCase(testEmail);

    expect(result, const Left(UserNotFoundFailure()));
    verify(() => mockRepository.resetPassword(testEmail)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('deberia retornar InvalidEmailFailure cuando el correo no es válido',
      () async {
    when(() => mockRepository.resetPassword(testEmail)).thenAnswer(
      (_) async => const Left(InvalidEmailFailure()),
    );

    final result = await resetPasswordUseCase(testEmail);

    expect(result, const Left(InvalidEmailFailure()));
    verify(() => mockRepository.resetPassword(testEmail)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('deberia retornar NetworkFailureAuth cuando hay error de conexión',
      () async {
    when(() => mockRepository.resetPassword(testEmail)).thenAnswer(
      (_) async => const Left(NetworkFailureAuth()),
    );

    final result = await resetPasswordUseCase(testEmail);

    expect(result, const Left(NetworkFailureAuth()));
    verify(() => mockRepository.resetPassword(testEmail)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
