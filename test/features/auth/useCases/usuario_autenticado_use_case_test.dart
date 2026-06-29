import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/usuario_autenticado_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helper.dart';

void main() {
  late MockAuthRepository mockRepository;
  late GetAuthenticatedUserUseCase getAuthenticatedUserUseCase;
  late MockFirebaseUser mockFirebaseUser;

  setUp(() {
    mockRepository = MockAuthRepository();
    getAuthenticatedUserUseCase = GetAuthenticatedUserUseCase(mockRepository);
    mockFirebaseUser = MockFirebaseUser();
  });

  group('cuando el usuario está autenticado y verificado', () {
    test('deberia retornar Right(UserModel) cuando el usuario está verificado',
        () async {
      when(() => mockFirebaseUser.emailVerified).thenReturn(true);
      when(() => mockFirebaseUser.uid).thenReturn('test-uid-123');

      when(() => mockRepository.getAuthenticatedUser()).thenAnswer(
        (_) async => Right(mockFirebaseUser),
      );

      when(() => mockRepository.getUserData('test-uid-123')).thenAnswer(
        (_) async => Right(testUser),
      );

      final result = await getAuthenticatedUserUseCase();

      expect(result, Right(testUser));
      verify(() => mockRepository.getAuthenticatedUser()).called(1);
      verify(() => mockRepository.getUserData('test-uid-123')).called(1);
      verifyNever(() => mockRepository.logout());
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('cuando el usuario no está verificado', () {
    test(
        'deberia cerrar sesión y retornar Right(null) cuando el correo no está verificado',
        () async {
      when(() => mockFirebaseUser.emailVerified).thenReturn(false);

      when(() => mockRepository.getAuthenticatedUser()).thenAnswer(
        (_) async => Right(mockFirebaseUser),
      );

      when(() => mockRepository.logout()).thenAnswer(
        (_) async => const Right(unit),
      );

      final result = await getAuthenticatedUserUseCase();

      expect(result, const Right(null));
      verify(() => mockRepository.getAuthenticatedUser()).called(1);
      verify(() => mockRepository.logout()).called(1);
      verifyNever(() => mockRepository.getUserData(any()));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('cuando ocurre un error', () {
    test('deberia retornar UnexpectedFailure cuando getAuthenticatedUser falla',
        () async {
      when(() => mockRepository.getAuthenticatedUser()).thenAnswer(
        (_) async => const Left(UnexpectedFailure()),
      );

      final result = await getAuthenticatedUserUseCase();

      expect(result, const Left(UnexpectedFailure()));
      verify(() => mockRepository.getAuthenticatedUser()).called(1);
      verifyNever(() => mockRepository.logout());
      verifyNever(() => mockRepository.getUserData(any()));
      verifyNoMoreInteractions(mockRepository);
    });

    test('deberia retornar UserDataNotFoundFailure cuando getUserData falla',
        () async {
      when(() => mockFirebaseUser.emailVerified).thenReturn(true);
      when(() => mockFirebaseUser.uid).thenReturn('test-uid-123');

      when(() => mockRepository.getAuthenticatedUser()).thenAnswer(
        (_) async => Right(mockFirebaseUser),
      );

      when(() => mockRepository.getUserData('test-uid-123')).thenAnswer(
        (_) async => const Left(UserDataNotFoundFailure()),
      );

      final result = await getAuthenticatedUserUseCase();

      expect(result, const Left(UserDataNotFoundFailure()));
      verify(() => mockRepository.getAuthenticatedUser()).called(1);
      verify(() => mockRepository.getUserData('test-uid-123')).called(1);
      verifyNever(() => mockRepository.logout());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
