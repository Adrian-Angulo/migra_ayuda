import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/auth/domain/entities/auth_user.dart';
import 'package:migra_ayuda/features/auth/domain/failures/auth_failures.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/auth/domain/usecases/auth_usecases.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/failures/users_failures.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';
import 'package:migra_ayuda/features/users/domain/usecases/complete_profile_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/create_user_profile_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/get_user_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

const fakeAuthUser = AuthUser(
  id: 'usuario-id-prueba-123',
  email: 'pedro@correo.com',
  displayName: 'Pedro García',
  isEmailVerified: true,
);

final fakeMigrant = Migrant(
  id: 'usuario-id-prueba-123',
  name: 'Pedro García',
  email: 'pedro@correo.com',
  originCountry: 'México',
  destinationCountry: 'Argentina',
  age: '35',
  role: 'Migrante',
  profileComplete: true,
);

void main() {
  late MockAuthRepository authRepository;
  late MockUserRepository userRepository;

  setUpAll(() {
    registerFallbackValue(fakeAuthUser);
    registerFallbackValue(fakeMigrant);
  });

  setUp(() {
    authRepository = MockAuthRepository();
    userRepository = MockUserRepository();
  });

  group('Auth - Inicio de sesión por correo', () {
    late LoginWithEmailUseCase loginWithEmail;

    setUp(() {
      loginWithEmail = LoginWithEmailUseCase(authRepository);
    });

    test(
      'retorna usuario autenticado cuando correo/contraseña son correctos',
      () async {
        // Arrange
        const email = 'pedro@correo.com';
        const password = 'claveSegura456';
        when(() => authRepository.loginWithEmail(email, password))
            .thenAnswer((_) async => const Right(fakeAuthUser));

        // Act
        final result = await loginWithEmail(email, password);

        // Assert
        expect(result, const Right(fakeAuthUser));
        verify(() => authRepository.loginWithEmail(email, password)).called(1);
      }, tags: ['sprint_1']
    );

    test(
      'retorna InvalidCredentialsFailure cuando credenciales son inválidas',
      () async {
        const email = 'pedro@correo.com';
        const password = 'claveIncorrecta';
        when(() => authRepository.loginWithEmail(any(), any()))
            .thenAnswer((_) async => const Left(InvalidCredentialsFailure()));

        final result = await loginWithEmail(email, password);

        expect(result.isLeft(), isTrue);
        expect(result.getLeft().toNullable(), isA<InvalidCredentialsFailure>());
        verify(() => authRepository.loginWithEmail(email, password)).called(1);
      },
      tags: ['sprint_1']
    );
  });

  group('Auth - Registro y creación de perfil de usuario', () {
    late RegisterWithEmailUseCase registerWithEmail;

    setUp(() {
      registerWithEmail =
          RegisterWithEmailUseCase(authRepository, userRepository);
    });

    const params = RegisterUserParams(
      name: 'Pedro García',
      email: 'pedro@correo.com',
      password: 'claveSegura456',
      originCountry: 'México',
      destinationCountry: 'Argentina',
      age: '35',
      role: 'Migrante',
      profileComplete: true,
    );

    test(
      'registra autenticación y crea el perfil del usuario exitosamente',
      () async {
        when(() => authRepository.registerWithEmail(any(), any()))
            .thenAnswer((_) async => const Right(fakeAuthUser));
        when(() => userRepository.createUser(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => authRepository.logout())
            .thenAnswer((_) async => const Right(null));

        final result = await registerWithEmail(params);

        expect(result, const Right(fakeAuthUser));
        verify(() =>
          authRepository.registerWithEmail(params.email, params.password)
        ).called(1);
        verify(() => userRepository.createUser(any())).called(1);
        verify(() => authRepository.logout()).called(1);
      },
      tags: ['sprint_1']
    );

    test(
      'revierte y elimina usuario si falla guardado de perfil',
      () async {
        when(() => authRepository.registerWithEmail(any(), any()))
            .thenAnswer((_) async => const Right(fakeAuthUser));
        when(() => userRepository.createUser(any()))
            .thenAnswer((_) async => const Left(UserProfileCreationFailedFailure()));
        when(() => authRepository.deleteCurrentUser())
            .thenAnswer((_) async => const Right(null));

        final result = await registerWithEmail(params);

        expect(result.isLeft(), isTrue);
        expect(result.getLeft().toNullable(),
            isA<UserProfileCreationFailedFailure>());
        verify(() =>
          authRepository.registerWithEmail(params.email, params.password)
        ).called(1);
        verify(() => userRepository.createUser(any())).called(1);
        verify(() => authRepository.deleteCurrentUser()).called(1);
      },
      tags: ['sprint_1']
    );
  });

  group('Auth - Inicio de sesión con Google', () {
    late LoginWithGoogleUseCase loginWithGoogle;

    setUp(() {
      loginWithGoogle = LoginWithGoogleUseCase(authRepository, userRepository);
    });

    test(
      'retorna perfil existente si ya está registrado con Google',
      () async {
        when(() => authRepository.authWithGoogle())
            .thenAnswer((_) async => const Right(fakeAuthUser));
        when(() => userRepository.getUserById('usuario-id-prueba-123'))
            .thenAnswer((_) async => Right(fakeMigrant));

        final result = await loginWithGoogle();

        expect(result, Right(fakeMigrant));
        verify(() => authRepository.authWithGoogle()).called(1);
        verify(() => userRepository.getUserById('usuario-id-prueba-123')).called(1);
        verifyNever(() => userRepository.createUser(any()));
      }, tags: ['sprint_1']
    );

    test(
      'crea nuevo perfil si es la primera vez con Google',
      () async {
        when(() => authRepository.authWithGoogle())
            .thenAnswer((_) async => const Right(fakeAuthUser));
        when(() => userRepository.getUserById('usuario-id-prueba-123'))
            .thenAnswer((_) async => const Right(null));
        when(() => userRepository.createUser(any()))
            .thenAnswer((_) async => const Right(null));

        final result = await loginWithGoogle();

        expect(result.isRight(), isTrue);
        final migrant = result.getRight().toNullable();
        expect(migrant?.id, 'usuario-id-prueba-123');
        expect(migrant?.email, 'pedro@correo.com');
        verify(() => authRepository.authWithGoogle()).called(1);
        verify(() => userRepository.getUserById('usuario-id-prueba-123')).called(1);
        verify(() => userRepository.createUser(any())).called(1);
      }, tags: ['sprint_1']
    );

    test(
      'retorna GoogleSignInCancelledFailure si usuario cancela popup de Google',
      () async {
        when(() => authRepository.authWithGoogle())
            .thenAnswer((_) async => const Left(GoogleSignInCancelledFailure()));

        final result = await loginWithGoogle();

        expect(result, const Left(GoogleSignInCancelledFailure()));
        verify(() => authRepository.authWithGoogle()).called(1);
        verifyNever(() => userRepository.getUserById(any()));
      },
      tags: ['sprint_1']
    );
  });

  group('Auth - Cierre de sesión', () {
    late LogoutUseCase logout;

    setUp(() {
      logout = LogoutUseCase(authRepository);
    });

    test(
      'cierra sesión exitosamente',
      () async {
        when(() => authRepository.logout())
            .thenAnswer((_) async => const Right(null));

        final result = await logout();

        expect(result, const Right(null));
        verify(() => authRepository.logout()).called(1);
      },
      tags: ['sprint_1']
    );

    test(
      'retorna ServerFailure si falla el cierre de sesión',
      () async {
        when(() => authRepository.logout())
          .thenAnswer((_) async =>
            const Left(ServerFailure(message: 'Error al desconectar')));

        final result = await logout();

        expect(result.isLeft(), isTrue);
        verify(() => authRepository.logout()).called(1);
      },
      tags: ['sprint_1']
    );
  });

  group('Auth - Recuperar contraseña', () {
    late ResetPasswordUseCase resetPassword;

    setUp(() {
      resetPassword = ResetPasswordUseCase(authRepository);
    });

    test(
      'envía correo de recuperación de contraseña exitosamente',
      () async {
        const email = 'pedro@correo.com';
        when(() => authRepository.resetPassword(email))
            .thenAnswer((_) async => const Right(null));

        final result = await resetPassword(email);

        expect(result, const Right(null));
        verify(() => authRepository.resetPassword(email)).called(1);
      },
      tags: ['sprint_1']
    );

    test(
      'retorna UserNotFoundAuthFailure si el correo no existe',
      () async {
        const email = 'noexiste@correo.com';
        when(() => authRepository.resetPassword(any()))
            .thenAnswer((_) async => const Left(UserNotFoundAuthFailure()));

        final result = await resetPassword(email);

        expect(result, const Left(UserNotFoundAuthFailure()));
        verify(() => authRepository.resetPassword(email)).called(1);
      },
      tags: ['sprint_1']
    );
  });

  group('Usuario - Obtener usuario/sesión actual', () {
    late GetCurrentUserUseCase getCurrentUser;

    setUp(() {
      getCurrentUser = GetCurrentUserUseCase(authRepository);
    });

    test(
      'retorna usuario autenticado si la sesión está activa',
      () async {
        when(() => authRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(fakeAuthUser));

        final result = await getCurrentUser();

        expect(result, const Right(fakeAuthUser));
        verify(() => authRepository.getCurrentUser()).called(1);
      },

      tags: ['sprint_1']
    );

    test(
      'retorna null si no hay sesión activa',
      () async {
        when(() => authRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));

        final result = await getCurrentUser();

        expect(result, const Right(null));
        verify(() => authRepository.getCurrentUser()).called(1);
      },
      tags: ['sprint_1']
    );
  });

  group('Usuario - Obtener perfil por ID', () {
    late GetUserProfileUseCase getUserProfile;

    setUp(() {
      getUserProfile = GetUserProfileUseCase(userRepository);
    });

    test(
      'retorna datos del perfil si el usuario existe en la base de datos',
      () async {
        when(() => userRepository.getUserById('usuario-id-prueba-123'))
            .thenAnswer((_) async => Right(fakeMigrant));

        final result = await getUserProfile('usuario-id-prueba-123');

        expect(result, Right(fakeMigrant));
        verify(() => userRepository.getUserById('usuario-id-prueba-123')).called(1);
      },
      tags: ['sprint_1']
    );

    test(
      'retorna UserNotFoundFailure si el perfil no existe',
      () async {
        when(() => userRepository.getUserById('id-no-existe'))
            .thenAnswer((_) async => const Left(UserNotFoundFailure()));

        final result = await getUserProfile('id-no-existe');

        expect(result, const Left(UserNotFoundFailure()));
        verify(() => userRepository.getUserById('id-no-existe')).called(1);
      },
      tags: ['sprint_1']
    );
  });

  group('Usuario - Crear perfil', () {
    late CreateUserProfileUseCase createUserProfile;

    setUp(() {
      createUserProfile = CreateUserProfileUseCase(userRepository);
    });

    test(
      'crea perfil en base de datos exitosamente',
      () async {
        when(() => userRepository.createUser(fakeMigrant))
            .thenAnswer((_) async => const Right(null));

        final result = await createUserProfile(fakeMigrant);

        expect(result, const Right(null));
        verify(() => userRepository.createUser(fakeMigrant)).called(1);
      },
      tags: ['sprint_1']
    );

    test(
      'retorna UserProfileCreationFailedFailure si falla al guardar en db',
      () async {
        when(() => userRepository.createUser(any()))
            .thenAnswer((_) async => const Left(UserProfileCreationFailedFailure()));

        final result = await createUserProfile(fakeMigrant);

        expect(result, const Left(UserProfileCreationFailedFailure()));
        verify(() => userRepository.createUser(fakeMigrant)).called(1);
      },
      tags: ['sprint_1']
    );
  });

  group('Usuario - Completar (actualizar) perfil', () {
    late CompleteProfileUseCase completeProfile;

    setUp(() {
      completeProfile = CompleteProfileUseCase(userRepository);
    });

    test(
      'actualiza país de origen, destino y edad exitosamente',
      () async {
        when(() => userRepository.completeProfile(
          id: 'usuario-id-prueba-123',
          originCountry: 'México',
          destinationCountry: 'Argentina',
          age: 35,
        )).thenAnswer((_) async => const Right(null));

        final result = await completeProfile(
          id: 'usuario-id-prueba-123',
          originCountry: 'México',
          destinationCountry: 'Argentina',
          age: 35,
        );

        expect(result, const Right(null));
        verify(() => userRepository.completeProfile(
          id: 'usuario-id-prueba-123',
          originCountry: 'México',
          destinationCountry: 'Argentina',
          age: 35,
        )).called(1);
      },
      tags: ['sprint_1']
    );

    test(
      'retorna UserProfileUpdateFailedFailure si falla la actualización',
      () async {
        when(() => userRepository.completeProfile(
          id: any(named: 'id'),
          originCountry: any(named: 'originCountry'),
          destinationCountry: any(named: 'destinationCountry'),
          age: any(named: 'age'),
        )).thenAnswer((_) async => const Left(UserProfileUpdateFailedFailure()));

        final result = await completeProfile(
          id: 'usuario-id-prueba-123',
          originCountry: 'México',
          destinationCountry: 'Argentina',
          age: 35,
        );

        expect(result, const Left(UserProfileUpdateFailedFailure()));
      },

      tags: ['sprint_1']
    );
  });
}
