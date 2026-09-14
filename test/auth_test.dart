import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/auth/domain/entities/auth_user.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/auth/domain/usecases/auth_usecases.dart';

import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';
import 'package:migra_ayuda/features/users/domain/usecases/complete_profile_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/create_user_profile_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/get_user_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

/// Simula el repositorio de autenticación
class MockAuthRepository extends Mock implements AuthRepository {}

/// Simula el repositorio de usuarios
class MockUserRepository extends Mock implements UserRepository {}

/// Datos de prueba
const fakeAuthUser = AuthUser(
  id: 'test-uid-123',
  email: 'juan@email.com',
  displayName: 'Juan Perez',
  isEmailVerified: true,
);

final fakeMigrant = Migrant(
  id: 'test-uid-123',
  name: 'Juan Perez',
  email: 'juan@email.com',
  originCountry: 'Colombia',
  destinationCountry: 'España',
  age: '28',
  role: 'Migrante',
  profileComplete: true,
);

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;

  setUpAll(() {
    registerFallbackValue(fakeAuthUser);
    registerFallbackValue(fakeMigrant);
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
  });

  group('LoginWithEmailUseCase', () {
    late LoginWithEmailUseCase useCase;

    setUp(() {
      useCase = LoginWithEmailUseCase(mockAuthRepository);
    });

    test(
        'debería iniciar sesión y retornar el usuario autenticado cuando las credenciales son correctas',
        () async {
      when(() => mockAuthRepository.loginWithEmail('juan@email.com', 'pass123'))
          .thenAnswer((_) async => const Right(fakeAuthUser));

      final result = await useCase('juan@email.com', 'pass123');

      expect(result, const Right(fakeAuthUser));
      verify(() =>
              mockAuthRepository.loginWithEmail('juan@email.com', 'pass123'))
          .called(1);
    });

    test(
        'debería retornar una falla de credenciales inválidas cuando el correo o contraseña son incorrectos',
        () async {
      when(() => mockAuthRepository.loginWithEmail(any(), any()))
          .thenAnswer((_) async => const Left(InvalidCredentialsFailure()));

      final result = await useCase('juan@email.com', 'wrong-pass');

      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<InvalidCredentialsFailure>());
      verify(() =>
              mockAuthRepository.loginWithEmail('juan@email.com', 'wrong-pass'))
          .called(1);
    });
  });

  group('RegisterWithEmailUseCase', () {
    late RegisterWithEmailUseCase useCase;

    setUp(() {
      useCase =
          RegisterWithEmailUseCase(mockAuthRepository, mockUserRepository);
    });

    const params = RegisterUserParams(
      name: 'Juan Perez',
      email: 'juan@email.com',
      password: 'pass123',
      originCountry: 'Colombia',
      destinationCountry: 'España',
      age: '28',
      role: 'Migrante',
      profileComplete: true,
    );

    test(
        'debería registrar credenciales en autenticación y crear el perfil del usuario exitosamente',
        () async {
      when(() => mockAuthRepository.registerWithEmail(any(), any()))
          .thenAnswer((_) async => const Right(fakeAuthUser));
      when(() => mockUserRepository.createUser(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result, const Right(fakeAuthUser));
      verify(() =>
              mockAuthRepository.registerWithEmail('juan@email.com', 'pass123'))
          .called(1);
      verify(() => mockUserRepository.createUser(any())).called(1);
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test(
        'debería revertir el registro eliminando el usuario en autenticación si ocurre un error al guardar el perfil',
        () async {

         
      when(() => mockAuthRepository.registerWithEmail(any(), any()))
          .thenAnswer((_) async => const Right(fakeAuthUser));
      when(() => mockUserRepository.createUser(any())).thenAnswer(
          (_) async => const Left(UserProfileCreationFailedFailure()));
      when(() => mockAuthRepository.deleteCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // Act: ejecución del caso de uso de registro
      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(),
          isA<UserProfileCreationFailedFailure>());
      verify(() =>
              mockAuthRepository.registerWithEmail('juan@email.com', 'pass123'))
          .called(1);
      verify(() => mockUserRepository.createUser(any())).called(1);
      verify(() => mockAuthRepository.deleteCurrentUser()).called(1);
    });
  });

  group('LoginWithGoogleUseCase', () {
    late LoginWithGoogleUseCase useCase;

    setUp(() {
      useCase = LoginWithGoogleUseCase(mockAuthRepository, mockUserRepository);
    });

    test(
        'debería retornar el perfil existente sin volver a crearlo cuando el usuario ya se ha registrado previamente',
        () async {
      when(() => mockAuthRepository.authWithGoogle())
          .thenAnswer((_) async => const Right(fakeAuthUser));
      when(() => mockUserRepository.getUserById('test-uid-123'))
          .thenAnswer((_) async => Right(fakeMigrant));

      final result = await useCase();

      expect(result, Right(fakeMigrant));
      verify(() => mockAuthRepository.authWithGoogle()).called(1);
      verify(() => mockUserRepository.getUserById('test-uid-123')).called(1);
      verifyNever(() => mockUserRepository.createUser(any()));
    });

    test(
        'debería crear un nuevo perfil en la base de datos cuando el usuario inicia sesión con Google por primera vez',
        () async {
      when(() => mockAuthRepository.authWithGoogle())
          .thenAnswer((_) async => const Right(fakeAuthUser));
      when(() => mockUserRepository.getUserById('test-uid-123'))
          .thenAnswer((_) async => const Right(null));
      when(() => mockUserRepository.createUser(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result.isRight(), isTrue);
      final migrant = result.getRight().toNullable();
      expect(migrant?.id, 'test-uid-123');
      expect(migrant?.email, 'juan@email.com');
      verify(() => mockAuthRepository.authWithGoogle()).called(1);
      verify(() => mockUserRepository.getUserById('test-uid-123')).called(1);
      verify(() => mockUserRepository.createUser(any())).called(1);
    });

    test(
        'debería retornar una falla de cancelación cuando el usuario cierra la ventana de Google',
        () async {
      when(() => mockAuthRepository.authWithGoogle())
          .thenAnswer((_) async => const Left(GoogleSignInCancelledFailure()));

      final result = await useCase();

      expect(result, const Left(GoogleSignInCancelledFailure()));
      verify(() => mockAuthRepository.authWithGoogle()).called(1);
      verifyNever(() => mockUserRepository.getUserById(any()));
    });
  });

  group('LogoutUseCase', () {
    late LogoutUseCase useCase;

    setUp(() {
      useCase = LogoutUseCase(mockAuthRepository);
    });

    test('debería cerrar la sesión del usuario exitosamente', () async {
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right(null));
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test(
        'debería retornar una falla si ocurre un error al desconectar la sesión',
        () async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async =>
          const Left(ServerFailure(message: 'Error al desconectar')));

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      verify(() => mockAuthRepository.logout()).called(1);
    });
  });

  group('ResetPasswordUseCase', () {
    late ResetPasswordUseCase useCase;

    setUp(() {
      useCase = ResetPasswordUseCase(mockAuthRepository);
    });

    test('debería enviar el correo de recuperación de contraseña exitosamente',
        () async {
      when(() => mockAuthRepository.resetPassword('juan@email.com'))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase('juan@email.com');

      expect(result, const Right(null));
      verify(() => mockAuthRepository.resetPassword('juan@email.com'))
          .called(1);
    });

    test(
        'debería retornar una falla de usuario no encontrado cuando el correo ingresado no existe',
        () async {
      when(() => mockAuthRepository.resetPassword(any()))
          .thenAnswer((_) async => const Left(UserNotFoundAuthFailure()));

      final result = await useCase('noexiste@email.com');

      expect(result, const Left(UserNotFoundAuthFailure()));
      verify(() => mockAuthRepository.resetPassword('noexiste@email.com'))
          .called(1);
    });
  });

  group('GetCurrentUserUseCase', () {
    late GetCurrentUserUseCase useCase;

    setUp(() {
      useCase = GetCurrentUserUseCase(mockAuthRepository);
    });

    test(
        'debería retornar el usuario autenticado cuando existe una sesión activa',
        () async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(fakeAuthUser));

      final result = await useCase();

      expect(result, const Right(fakeAuthUser));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });

    test('debería retornar null cuando no hay ninguna sesión activa', () async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right(null));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });
  });

  group('GetUserProfileUseCase', () {
    late GetUserProfileUseCase useCase;

    setUp(() {
      useCase = GetUserProfileUseCase(mockUserRepository);
    });

    test(
        'debería retornar los datos del perfil cuando el usuario existe en la base de datos',
        () async {
      when(() => mockUserRepository.getUserById('test-uid-123'))
          .thenAnswer((_) async => Right(fakeMigrant));

      final result = await useCase('test-uid-123');

      expect(result, Right(fakeMigrant));
      verify(() => mockUserRepository.getUserById('test-uid-123')).called(1);
    });

    test(
        'debería retornar una falla de usuario no encontrado cuando el perfil no existe en la base de datos',
        () async {
      when(() => mockUserRepository.getUserById('no-id'))
          .thenAnswer((_) async => const Left(UserNotFoundFailure()));

      final result = await useCase('no-id');

      expect(result, const Left(UserNotFoundFailure()));
      verify(() => mockUserRepository.getUserById('no-id')).called(1);
    });
  });

  group('CreateUserProfileUseCase', () {
    late CreateUserProfileUseCase useCase;

    setUp(() {
      useCase = CreateUserProfileUseCase(mockUserRepository);
    });

    test('debería crear el perfil del usuario en la base de datos exitosamente',
        () async {
      when(() => mockUserRepository.createUser(fakeMigrant))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(fakeMigrant);

      expect(result, const Right(null));
      verify(() => mockUserRepository.createUser(fakeMigrant)).called(1);
    });

    test(
        'debería retornar una falla de creación cuando ocurre un error al guardar en la base de datos',
        () async {
      when(() => mockUserRepository.createUser(any())).thenAnswer(
          (_) async => const Left(UserProfileCreationFailedFailure()));

      final result = await useCase(fakeMigrant);

      expect(result, const Left(UserProfileCreationFailedFailure()));
      verify(() => mockUserRepository.createUser(fakeMigrant)).called(1);
    });
  });

  group('CompleteProfileUseCase', () {
    late CompleteProfileUseCase useCase;

    setUp(() {
      useCase = CompleteProfileUseCase(mockUserRepository);
    });

    test('debería actualizar los campos de origen, destino y edad exitosamente',
        () async {
      when(() => mockUserRepository.completeProfile(
            id: 'test-uid-123',
            originCountry: 'Colombia',
            destinationCountry: 'España',
            age: 28,
          )).thenAnswer((_) async => const Right(null));

      final result = await useCase(
        id: 'test-uid-123',
        originCountry: 'Colombia',
        destinationCountry: 'España',
        age: 28,
      );

      expect(result, const Right(null));
      verify(() => mockUserRepository.completeProfile(
            id: 'test-uid-123',
            originCountry: 'Colombia',
            destinationCountry: 'España',
            age: 28,
          )).called(1);
    });

    test(
        'debería retornar una falla de actualización cuando ocurre un error al completar el perfil',
        () async {
      when(() => mockUserRepository.completeProfile(
                id: any(named: 'id'),
                originCountry: any(named: 'originCountry'),
                destinationCountry: any(named: 'destinationCountry'),
                age: any(named: 'age'),
              ))
          .thenAnswer(
              (_) async => const Left(UserProfileUpdateFailedFailure()));

      final result = await useCase(
        id: 'test-uid-123',
        originCountry: 'Colombia',
        destinationCountry: 'España',
        age: 28,
      );

      expect(result, const Left(UserProfileUpdateFailedFailure()));
    });
  });
}
