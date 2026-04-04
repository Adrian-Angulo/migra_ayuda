import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/iniciar_sesion_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helper.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late MockFirebaseUser mockFirebaseUser;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
    mockFirebaseUser = MockFirebaseUser();
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';

  test('deberia retornar Right(null) cuando el inicio de sesión es exitoso',
      () async {
    when(() => mockRepository.login(testEmail, testPassword)).thenAnswer(
      (_) async => Right(mockFirebaseUser),
    );

    final result = await loginUseCase(testEmail, testPassword);

    expect(result, const Right(null));
    verify(() => mockRepository.login(testEmail, testPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test(
      'deberia retornar InvalidCredentialFailure cuando las credenciales son incorrectas',
      () async {
    when(() => mockRepository.login(testEmail, testPassword)).thenAnswer(
      (_) async => const Left(InvalidCredentialFailure()),
    );

    final result = await loginUseCase(testEmail, testPassword);

    expect(result, const Left(InvalidCredentialFailure()));
    verify(() => mockRepository.login(testEmail, testPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('deberia retornar UserNotFoundFailure cuando el usuario no existe',
      () async {
    when(() => mockRepository.login(testEmail, testPassword)).thenAnswer(
      (_) async => const Left(UserNotFoundFailure()),
    );

    final result = await loginUseCase(testEmail, testPassword);

    expect(result, const Left(UserNotFoundFailure()));
    verify(() => mockRepository.login(testEmail, testPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('deberia retornar InvalidEmailFailure cuando el correo no es válido',
      () async {
    when(() => mockRepository.login(testEmail, testPassword)).thenAnswer(
      (_) async => const Left(InvalidEmailFailure()),
    );

    final result = await loginUseCase(testEmail, testPassword);

    expect(result, const Left(InvalidEmailFailure()));
    verify(() => mockRepository.login(testEmail, testPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('deberia retornar NetworkFailureAuth cuando hay error de conexión',
      () async {
    when(() => mockRepository.login(testEmail, testPassword)).thenAnswer(
      (_) async => const Left(NetworkFailureAuth()),
    );

    final result = await loginUseCase(testEmail, testPassword);

    expect(result, const Left(NetworkFailureAuth()));
    verify(() => mockRepository.login(testEmail, testPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
