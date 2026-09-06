import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/features/auth/domain/entities/auth_user.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:migra_ayuda/features/auth/domain/usecases/register_with_email_usecase.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';
import 'package:mocktail/mocktail.dart';



/// Simula el repositorio de autenticación
class MockAuthRepository extends Mock implements AuthRepository {}

/// Simula el repositorio de usuarios
class MockUserRepository extends Mock implements UserRepository {}

/// Entidad de usuario autenticado ficticio
const fakeAuthUser = AuthUser(
  id: 'test-uid-123',
  email: 'juan@email.com',
  displayName: 'Juan Perez',
  isEmailVerified: true,
);

/// Entidad de perfil ficticio
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
  setUpAll(() {
    registerFallbackValue(fakeAuthUser);
    registerFallbackValue(fakeMigrant);
  });

  // 1. PRUEBAS DE LA ENTIDAD MIGRANTE
  group('Migrant Entity - Validación de datos y estructura', () {
    test('Crea una entidad Migrant correctamente con valores por defecto', () {
      final defaultMigrant = Migrant(
        id: '123',
        name: 'Ana Gomez',
        email: 'ana@email.com',
        originCountry: '-',
        destinationCountry: '-',
        age: '-',
      );

      expect(defaultMigrant.role, 'Migrante');
      expect(defaultMigrant.profileComplete, false);
      expect(defaultMigrant.name, 'Ana Gomez');
    });

    test('copyWith crea una copia con campos actualizados', () {
      final updated = fakeMigrant.copyWith(
        originCountry: 'Perú',
        age: '30',
      );

      expect(updated.originCountry, 'Perú');
      expect(updated.age, '30');
      expect(updated.name, fakeMigrant.name);
    });
  });

  // 2. PRUEBAS DE ACCIONES DEL REPOSITORIO DE AUTENTICACIÓN (AuthRepository)
  group('AuthRepository - Acciones de autenticación', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    // --- ACCIÓN: LOGIN CON EMAIL ---
    group('loginWithEmail', () {
      test('debe retornar un AuthUser cuando las credenciales son correctas',
          () async {
        when(() => mockAuthRepository.loginWithEmail(
              'juan@email.com',
              'password123',
            )).thenAnswer((_) async => fakeAuthUser);

        final result = await mockAuthRepository.loginWithEmail(
          'juan@email.com',
          'password123',
        );

        expect(result, equals(fakeAuthUser));
        expect(result.email, 'juan@email.com');
        verify(() => mockAuthRepository.loginWithEmail(
              'juan@email.com',
              'password123',
            )).called(1);
      });

      test('debe lanzar excepción cuando la contraseña es incorrecta',
          () async {
        when(() => mockAuthRepository.loginWithEmail(any(), any()))
            .thenThrow(Exception('wrong-password'));

        expect(
          () => mockAuthRepository.loginWithEmail(
            'juan@email.com',
            'clave_invalida',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    // --- ACCIÓN: REGISTRAR CREDENCIALES ---
    group('registerWithEmail', () {
      test('debe registrar y retornar AuthUser satisfactoriamente', () async {
        when(() => mockAuthRepository.registerWithEmail(any(), any()))
            .thenAnswer((_) async => fakeAuthUser);

        final result = await mockAuthRepository.registerWithEmail(
          'juan@email.com',
          'password123',
        );

        expect(result, equals(fakeAuthUser));
        verify(() => mockAuthRepository.registerWithEmail(
              'juan@email.com',
              'password123',
            )).called(1);
      });
    });

    // --- ACCIÓN: AUTENTICACIÓN CON GOOGLE ---
    group('authWithGoogle', () {
      test('debe retornar AuthUser al autenticarse con Google con éxito',
          () async {
        when(() => mockAuthRepository.authWithGoogle())
            .thenAnswer((_) async => fakeAuthUser);

        final result = await mockAuthRepository.authWithGoogle();

        expect(result, equals(fakeAuthUser));
        verify(() => mockAuthRepository.authWithGoogle()).called(1);
      });

      test('debe lanzar excepción si el usuario cancela la ventana de Google',
          () async {
        when(() => mockAuthRepository.authWithGoogle())
            .thenThrow(Exception('operation_cancelled'));

        expect(
          () => mockAuthRepository.authWithGoogle(),
          throwsA(isA<Exception>()),
        );
      });
    });

    // --- ACCIÓN: CERRAR SESIÓN ---
    group('logout', () {
      test('debe cerrar la sesión correctamente', () async {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

        await expectLater(mockAuthRepository.logout(), completes);
        verify(() => mockAuthRepository.logout()).called(1);
      });
    });

    // --- ACCIÓN: RECUPERAR CONTRASEÑA ---
    group('resetPassword', () {
      test('debe solicitar el restablecimiento de contraseña exitosamente',
          () async {
        when(() => mockAuthRepository.resetPassword(any()))
            .thenAnswer((_) async {});

        await expectLater(
          mockAuthRepository.resetPassword('recuperar@email.com'),
          completes,
        );

        verify(() => mockAuthRepository.resetPassword('recuperar@email.com'))
            .called(1);
      });
    });

    // --- ACCIÓN: SESIÓN ACTUAL ---
    group('getCurrentUser', () {
      test('retorna el usuario si existe sesión activa', () async {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => fakeAuthUser);

        final user = await mockAuthRepository.getCurrentUser();

        expect(user, isNotNull);
        expect(user?.id, 'test-uid-123');
      });

      test('retorna null si no hay sesión activa', () async {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => null);

        final user = await mockAuthRepository.getCurrentUser();

        expect(user, isNull);
      });
    });
  });

  // 3. PRUEBAS DEL REPOSITORIO DE USUARIOS (UserRepository)
  group('UserRepository - Gestión de perfiles y usuarios', () {
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockUserRepository = MockUserRepository();
    });

    test('getUserById retorna el perfil según el UID', () async {
      when(() => mockUserRepository.getUserById('test-uid-123'))
          .thenAnswer((_) async => fakeMigrant);

      final result = await mockUserRepository.getUserById('test-uid-123');

      expect(result, isNotNull);
      expect(result?.name, 'Juan Perez');
      expect(result?.role, 'Migrante');
    });

    test('createUser crea el perfil de usuario correctamente', () async {
      when(() => mockUserRepository.createUser(any()))
          .thenAnswer((_) async {});

      await expectLater(
        mockUserRepository.createUser(fakeMigrant),
        completes,
      );

      verify(() => mockUserRepository.createUser(fakeMigrant)).called(1);
    });

    test('completeProfile actualiza los campos de origen, destino y edad',
        () async {
      when(() => mockUserRepository.completeProfile(
            id: any(named: 'id'),
            originCountry: any(named: 'originCountry'),
            destinationCountry: any(named: 'destinationCountry'),
            age: any(named: 'age'),
          )).thenAnswer((_) async {});

      await expectLater(
        mockUserRepository.completeProfile(
          id: 'test-uid-123',
          originCountry: 'Colombia',
          destinationCountry: 'España',
          age: 28,
        ),
        completes,
      );

      verify(() => mockUserRepository.completeProfile(
            id: 'test-uid-123',
            originCountry: 'Colombia',
            destinationCountry: 'España',
            age: 28,
          )).called(1);
    });
  });

  // 4. PRUEBAS DEL CASO DE USO DE REGISTRO (Coordinación Auth + Users)
  group('RegisterWithEmailUseCase - Coordinación de Auth y Users en el caso de uso', () {
    late MockAuthRepository mockAuthRepository;
    late MockUserRepository mockUserRepository;
    late RegisterWithEmailUseCase registerUseCase;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockUserRepository = MockUserRepository();
      registerUseCase = RegisterWithEmailUseCase(
        mockAuthRepository,
        mockUserRepository,
      );
    });

    test('registra credenciales en Auth y crea el perfil en Users', () async {
      when(() => mockAuthRepository.registerWithEmail(any(), any()))
          .thenAnswer((_) async => fakeAuthUser);
      when(() => mockUserRepository.createUser(any()))
          .thenAnswer((_) async {});
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async {});

      final params = RegisterUserParams(
        name: 'Juan Perez',
        email: 'juan@email.com',
        password: 'password123',
        originCountry: 'Colombia',
        destinationCountry: 'España',
        age: '28',
        role: 'Migrante',
        profileComplete: true,
      );

      final result = await registerUseCase(params);

      expect(result.id, fakeAuthUser.id);
      expect(result.email, fakeAuthUser.email);
      verify(() => mockAuthRepository.registerWithEmail('juan@email.com', 'password123')).called(1);
      verify(() => mockUserRepository.createUser(any())).called(1);
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('elimina el usuario en Auth (rollback) si la creación en Users falla', () async {
      when(() => mockAuthRepository.registerWithEmail(any(), any()))
          .thenAnswer((_) async => fakeAuthUser);
      when(() => mockUserRepository.createUser(any()))
          .thenThrow(Exception('Firestore write failed'));
      when(() => mockAuthRepository.deleteCurrentUser())
          .thenAnswer((_) async {});

      const params = RegisterUserParams(
        name: 'Juan Perez',
        email: 'juan@email.com',
        password: 'password123',
        originCountry: 'Colombia',
        destinationCountry: 'España',
        age: '28',
        role: 'Migrante',
        profileComplete: true,
      );

      await expectLater(
        registerUseCase(params),
        throwsA(isA<Exception>()),
      );

      verify(() => mockAuthRepository.registerWithEmail('juan@email.com', 'password123')).called(1);
      verify(() => mockUserRepository.createUser(any())).called(1);
      verify(() => mockAuthRepository.deleteCurrentUser()).called(1);
    });
  });

  // 5. PRUEBAS DEL CASO DE USO DE LOGIN CON GOOGLE
  group('LoginWithGoogleUseCase - Login y creación automática de perfil si no existe', () {
    late MockAuthRepository mockAuthRepository;
    late MockUserRepository mockUserRepository;
    late LoginWithGoogleUseCase loginGoogleUseCase;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockUserRepository = MockUserRepository();
      loginGoogleUseCase = LoginWithGoogleUseCase(
        mockAuthRepository,
        mockUserRepository,
      );
    });

    test('retorna perfil existente si el usuario ya está en Firestore', () async {
      when(() => mockAuthRepository.authWithGoogle())
          .thenAnswer((_) async => fakeAuthUser);
      when(() => mockUserRepository.getUserById('test-uid-123'))
          .thenAnswer((_) async => fakeMigrant);

      final result = await loginGoogleUseCase();

      expect(result.id, 'test-uid-123');
      expect(result.name, 'Juan Perez');
      verify(() => mockAuthRepository.authWithGoogle()).called(1);
      verify(() => mockUserRepository.getUserById('test-uid-123')).called(1);
      verifyNever(() => mockUserRepository.createUser(any()));
    });

    test('crea nuevo perfil en Firestore si es la primera vez que inicia sesión', () async {
      when(() => mockAuthRepository.authWithGoogle())
          .thenAnswer((_) async => fakeAuthUser);
      when(() => mockUserRepository.getUserById('test-uid-123'))
          .thenAnswer((_) async => null);
      when(() => mockUserRepository.createUser(any()))
          .thenAnswer((_) async {});

      final result = await loginGoogleUseCase();

      expect(result.id, 'test-uid-123');
      expect(result.email, 'juan@email.com');
      verify(() => mockAuthRepository.authWithGoogle()).called(1);
      verify(() => mockUserRepository.getUserById('test-uid-123')).called(1);
      verify(() => mockUserRepository.createUser(any())).called(1);
    });
  });
}




