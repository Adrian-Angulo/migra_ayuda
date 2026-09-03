import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';


/// Simula el repositorio de autenticación para pruebas sin tocar servicios externos
class MockAuthRepository extends Mock implements AuthRepository {}

/// Simula un objeto User de Firebase Auth
class FakeUser extends Fake implements User {
  @override
  String get uid => 'test-uid-123';

  @override
  String get email => 'test@email.com';
}

/// Simula la credencial devuelta al autenticarse con Google
class FakeUserCredential extends Fake implements UserCredential {}

/// Modelo de usuario ficticio reutilizable en los tests
final fakeUserModel = UserModel(
  id: 'test-uid-123',
  name: 'Juan Perez',
  email: 'juan@email.com',
  originCountry: 'Colombia',
  destinationCountry: 'España',
  age: '28',
  password: 'password123',
  role: 'Migrante',
  profileComplete: true,
);

void main() {
  // Registramos valores de fallback para que mocktail acepte any() con estos tipos
  setUpAll(() {
    registerFallbackValue(fakeUserModel);
    registerFallbackValue(FakeUserCredential());
  });

  // 1. PRUEBAS DEL MODELO DE USUARIO (UserModel)

  group('UserModel - Validación de datos y estructura', () {
    test('toMap() convierte las propiedades del usuario a un Map correctamente', () {
      // 1. Convertimos el modelo a Map
      final map = fakeUserModel.toMap();

      // 2. Verificamos que contenga exactamente los campos requeridos
      expect(map['name'], 'Juan Perez');
      expect(map['email'], 'juan@email.com');
      expect(map['originCountry'], 'Colombia');
      expect(map['destinationCountry'], 'España');
      expect(map['age'], '28');
      expect(map['role'], 'Migrante');
      expect(map['profileComplete'], true);
      expect(map['createdAt'], isA<String>());
    });

    test('Debe asignar valores por defecto correctos (rol Migrante y perfil incompleto)', () {
      // 1. Creamos un usuario solo con los campos obligatorios
      final defaultUser = UserModel(
        name: 'Ana Gomez',
        email: 'ana@email.com',
        password: 'password123',
      );

      // 2. Comprobamos los valores asignados por defecto
      expect(defaultUser.role, 'Migrante');
      expect(defaultUser.profileComplete, false);
      expect(defaultUser.originCountry, isNull);
      expect(defaultUser.destinationCountry, isNull);
    });
  });

  // 2. PRUEBAS DE ACCIONES DEL REPOSITORIO (AuthRepository)

  group('AuthRepository - Acciones principales de autenticación', () {
    late MockAuthRepository mockRepository;
    late FakeUser fakeUser;
    late FakeUserCredential fakeCredential;

    setUp(() {
      mockRepository = MockAuthRepository();
      fakeUser = FakeUser();
      fakeCredential = FakeUserCredential();
    });

    // --- ACCIÓN: INICIAR SESIÓN (LOGIN) ---
    group('login', () {
      test('debe retornar un usuario cuando las credenciales son correctas', () async {
        // Simulamos respuesta exitosa del repositorio
        when(() => mockRepository.login('juan@email.com', 'password123'))
            .thenAnswer((_) async => fakeUser);

        // Ejecutamos login
        final result = await mockRepository.login('juan@email.com', 'password123');

        // Validaciones
        expect(result, equals(fakeUser));
        expect(result.email, 'test@email.com');
        verify(() => mockRepository.login('juan@email.com', 'password123')).called(1);
      });

      test('debe lanzar excepción cuando la contraseña es incorrecta', () async {
        // Simulamos error de autenticación por contraseña errónea
        when(() => mockRepository.login(any(), any()))
            .thenThrow(FirebaseAuthException(code: 'wrong-password'));

        // Verificamos que se propague la excepción
        expect(
          () => mockRepository.login('juan@email.com', 'clave_invalida'),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    // --- ACCIÓN: REGISTRAR USUARIO ---
    group('registerUser', () {
      test('debe completar el registro de usuario satisfactoriamente', () async {
        // Simulamos registro exitoso sin retorno
        when(() => mockRepository.registerUser(any())).thenAnswer((_) async {});

        // Validamos que complete la operación sin lanzar error
        await expectLater(
          mockRepository.registerUser(fakeUserModel),
          completes,
        );

        verify(() => mockRepository.registerUser(fakeUserModel)).called(1);
      });

      test('debe fallar si el correo electrónico ya se encuentra registrado', () async {
        // Simulamos excepción de email duplicado
        when(() => mockRepository.registerUser(any()))
            .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

        expect(
          () => mockRepository.registerUser(fakeUserModel),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    // --- ACCIÓN: AUTENTICACIÓN CON GOOGLE ---
    group('authWithGoogle', () {
      test('debe retornar credencial al autenticarse con Google con éxito', () async {
        when(() => mockRepository.authWithGoogle())
            .thenAnswer((_) async => fakeCredential);

        final result = await mockRepository.authWithGoogle();

        expect(result, equals(fakeCredential));
        verify(() => mockRepository.authWithGoogle()).called(1);
      });

      test('debe lanzar excepción si el usuario cancela la ventana de Google', () async {
        when(() => mockRepository.authWithGoogle())
            .thenThrow(FirebaseAuthException(code: 'popup-closed-by-user'));

        expect(
          () => mockRepository.authWithGoogle(),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('verifyOrCreateGoogleUser debe retornar los datos del UserModel', () async {
        when(() => mockRepository.verifyOrCreateGoogleUser(any()))
            .thenAnswer((_) async => fakeUserModel);

        final result = await mockRepository.verifyOrCreateGoogleUser(fakeCredential);

        expect(result.id, 'test-uid-123');
        expect(result.email, 'juan@email.com');
        verify(() => mockRepository.verifyOrCreateGoogleUser(any())).called(1);
      });
    });

    // --- ACCIÓN: CERRAR SESIÓN (LOGOUT) ---
    group('logout', () {
      test('debe cerrar la sesión del usuario correctamente', () async {
        when(() => mockRepository.logout()).thenAnswer((_) async {});

        await expectLater(mockRepository.logout(), completes);
        verify(() => mockRepository.logout()).called(1);
      });
    });

    // --- ACCIÓN: CONSULTAR SESIÓN Y PERFIL ---
    group('getAuthenticatedUser y getUserData', () {
      test('getAuthenticatedUser retorna el usuario si existe sesión activa', () async {
        when(() => mockRepository.getAuthenticatedUser())
            .thenAnswer((_) async => fakeUser);

        final user = await mockRepository.getAuthenticatedUser();

        expect(user, isNotNull);
        expect(user?.uid, 'test-uid-123');
      });

      test('getAuthenticatedUser retorna null si no hay sesión activa', () async {
        when(() => mockRepository.getAuthenticatedUser())
            .thenAnswer((_) async => null);

        final user = await mockRepository.getAuthenticatedUser();

        expect(user, isNull);
      });

      test('getUserData retorna el perfil del usuario según su UID', () async {
        when(() => mockRepository.getUserData('test-uid-123'))
            .thenAnswer((_) async => fakeUserModel);

        final data = await mockRepository.getUserData('test-uid-123');

        expect(data.name, 'Juan Perez');
        expect(data.role, 'Migrante');
      });
    });

    // --- ACCIÓN: RECUPERAR CONTRASEÑA ---
    group('resetPassword', () {
      test('debe solicitar el restablecimiento de contraseña exitosamente', () async {
        when(() => mockRepository.resetPassword(any())).thenAnswer((_) async {});

        await expectLater(
          mockRepository.resetPassword('recuperar@email.com'),
          completes,
        );

        verify(() => mockRepository.resetPassword('recuperar@email.com')).called(1);
      });

      test('debe lanzar error cuando el email no existe en la base de datos', () async {
        when(() => mockRepository.resetPassword(any()))
            .thenThrow(FirebaseAuthException(code: 'user-not-found'));

        expect(
          () => mockRepository.resetPassword('noexiste@email.com'),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    // --- ACCIÓN: COMPLETAR PERFIL ---
    group('completeProfile', () {
      test('debe actualizar los datos de perfil exitosamente', () async {
        when(() => mockRepository.completeProfile(
              originCountry: any(named: 'originCountry'),
              destinationCountry: any(named: 'destinationCountry'),
              age: any(named: 'age'),
            )).thenAnswer((_) async {});

        await expectLater(
          mockRepository.completeProfile(
            originCountry: 'Colombia',
            destinationCountry: 'España',
            age: 28,
          ),
          completes,
        );

        verify(() => mockRepository.completeProfile(
              originCountry: 'Colombia',
              destinationCountry: 'España',
              age: 28,
            )).called(1);
      });

      test('debe fallar si los datos requeridos son inválidos', () async {
        when(() => mockRepository.completeProfile(
              originCountry: any(named: 'originCountry'),
              destinationCountry: any(named: 'destinationCountry'),
              age: any(named: 'age'),
            )).thenThrow(Exception('Campos requeridos vacíos'));

        expect(
          () => mockRepository.completeProfile(
            originCountry: '',
            destinationCountry: '',
            age: 0,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });


    
}
