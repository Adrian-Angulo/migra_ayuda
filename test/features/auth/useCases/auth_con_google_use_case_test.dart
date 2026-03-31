import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/auth_con_google_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helper.dart';

void main() {
  late MockAuthRepository mockRepository;
  late AuthWithGoogleUseCase authWithGoogleUseCase;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockRepository = MockAuthRepository();
    authWithGoogleUseCase = AuthWithGoogleUseCase(mockRepository);
    mockUserCredential = MockUserCredential();
  });

  group('cuando la autenticación con Google es exitosa', () {
    test(
        'deberia retornar Right(UserModel) cuando el usuario se autentica y se verifica/crea correctamente',
        () async {
      when(() => mockRepository.authWithGoogle()).thenAnswer(
        (_) async => Right(mockUserCredential),
      );

      when(() => mockRepository.verifyOrCreateGoogleUser(mockUserCredential))
          .thenAnswer(
        (_) async => Right(testUser),
      );

      final result = await authWithGoogleUseCase();

      expect(result, Right(testUser));
      verify(() => mockRepository.authWithGoogle()).called(1);
      verify(() => mockRepository.verifyOrCreateGoogleUser(mockUserCredential))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'deberia retornar Right(UserModel) con perfil incompleto cuando es un usuario nuevo',
        () async {
      when(() => mockRepository.authWithGoogle()).thenAnswer(
        (_) async => Right(mockUserCredential),
      );

      when(() => mockRepository.verifyOrCreateGoogleUser(mockUserCredential))
          .thenAnswer(
        (_) async => Right(testIncompleteUser),
      );

      final result = await authWithGoogleUseCase();

      expect(result, Right(testIncompleteUser));
      verify(() => mockRepository.authWithGoogle()).called(1);
      verify(() => mockRepository.verifyOrCreateGoogleUser(mockUserCredential))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('cuando ocurre un error en authWithGoogle', () {
    test('deberia retornar OperationCancelledFailure cuando el usuario cancela',
        () async {
      when(() => mockRepository.authWithGoogle()).thenAnswer(
        (_) async => const Left(OperationCancelledFailure()),
      );

      final result = await authWithGoogleUseCase();

      expect(result, const Left(OperationCancelledFailure()));
      verify(() => mockRepository.authWithGoogle()).called(1);
      verifyNever(
          () => mockRepository.verifyOrCreateGoogleUser(mockUserCredential));
      verifyNoMoreInteractions(mockRepository);
    });

    test('deberia retornar NetworkFailureAuth cuando hay error de conexión',
        () async {
      when(() => mockRepository.authWithGoogle()).thenAnswer(
        (_) async => const Left(NetworkFailureAuth()),
      );

      final result = await authWithGoogleUseCase();

      expect(result, const Left(NetworkFailureAuth()));
      verify(() => mockRepository.authWithGoogle()).called(1);
      verifyNever(
          () => mockRepository.verifyOrCreateGoogleUser(mockUserCredential));
      verifyNoMoreInteractions(mockRepository);
    });

    test('deberia retornar UnexpectedFailure cuando ocurre un error inesperado',
        () async {
      when(() => mockRepository.authWithGoogle()).thenAnswer(
        (_) async => const Left(UnexpectedFailure()),
      );

      final result = await authWithGoogleUseCase();

      expect(result, const Left(UnexpectedFailure()));
      verify(() => mockRepository.authWithGoogle()).called(1);
      verifyNever(
          () => mockRepository.verifyOrCreateGoogleUser(mockUserCredential));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('cuando ocurre un error en verifyOrCreateGoogleUser', () {
    test(
        'deberia retornar UnexpectedFailure cuando falla la verificación/creación del usuario',
        () async {
      when(() => mockRepository.authWithGoogle()).thenAnswer(
        (_) async => Right(mockUserCredential),
      );

      when(() => mockRepository.verifyOrCreateGoogleUser(mockUserCredential))
          .thenAnswer(
        (_) async => const Left(UnexpectedFailure()),
      );

      final result = await authWithGoogleUseCase();

      expect(result, const Left(UnexpectedFailure()));
      verify(() => mockRepository.authWithGoogle()).called(1);
      verify(() => mockRepository.verifyOrCreateGoogleUser(mockUserCredential))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'deberia retornar UserDataNotFoundFailure cuando no se encuentran los datos del usuario',
        () async {
      when(() => mockRepository.authWithGoogle()).thenAnswer(
        (_) async => Right(mockUserCredential),
      );

      when(() => mockRepository.verifyOrCreateGoogleUser(mockUserCredential))
          .thenAnswer(
        (_) async => const Left(UserDataNotFoundFailure()),
      );

      final result = await authWithGoogleUseCase();

      expect(result, const Left(UserDataNotFoundFailure()));
      verify(() => mockRepository.authWithGoogle()).called(1);
      verify(() => mockRepository.verifyOrCreateGoogleUser(mockUserCredential))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
