import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class FakeUser extends Fake implements User {}
class FakeUserCredential extends Fake implements UserCredential {}


void main() {
  group('Auth', () {
    late MockAuthRepository mockRepository;
    late FakeUser fakeUser;
    late FakeUserCredential fakeUserCredential;
    late UserModel fakeUserModel;

    setUp(() {
      mockRepository = MockAuthRepository();
      fakeUser = FakeUser();
      fakeUserCredential = FakeUserCredential();
      fakeUserModel = UserModel(
        id: 'test-uid',
        email: 'test@email.com',
        name: 'Test User',
        originCountry: 'Colombia',
        destinationCountry: 'España',
        age: '30',
        password: '',
      );
    });

    tearDown(() {
      // Limpieza después de cada test
    });
    // --- login ---
    test('deberia retornar un User en inicio de sesion exitoso', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => fakeUser);

      final result =
          await mockRepository.login('test@email.com', 'password123');
      expect(result, equals(fakeUser));
      verify(() => mockRepository.login(any(), any())).called(1);
    });

    test('deberia lanzar excepcion cuando las credenciales son invalidas',
        () async {
      when(() => mockRepository.login(any(), any()))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));
      expect(
        () => mockRepository.login('test@email.com', 'wrongpassword'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    // --- registerUser ---
    test('deberia completar el registro sin errores', () async {
      when(() => mockRepository.registerUser(fakeUserModel)).thenAnswer((_) async {});
      
      await expectLater(
        mockRepository.registerUser(fakeUserModel),
        completes,
      );
      verify(() => mockRepository.registerUser(fakeUserModel)).called(1);
    });

    test('deberia lanzar excepcion si el email ya esta en uso', () async {
      when(() => mockRepository.registerUser(fakeUserModel))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => mockRepository.registerUser(fakeUserModel),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    // --- authWithGoogle ---
    test('deberia retornar UserCredential en autenticacion exitosa con Google',
        () async {
      when(() => mockRepository.authWithGoogle())
          .thenAnswer((_) async => fakeUserCredential);

      final result = await mockRepository.authWithGoogle();

      expect(result, equals(fakeUserCredential));
      verify(() => mockRepository.authWithGoogle()).called(1);
    });

    test('deberia lanzar excepcion si el usuario cancela el flujo de Google',
        () async {
      when(() => mockRepository.authWithGoogle())
          .thenThrow(FirebaseAuthException(code: 'popup-closed-by-user'));

      expect(
        () => mockRepository.authWithGoogle(),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    // --- logout ---
    test('deberia cerrar sesion exitosamente', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      await expectLater(mockRepository.logout(), completes);
      verify(() => mockRepository.logout()).called(1);
    });

    // --- getAuthenticatedUser ---
    test('deberia retornar el usuario autenticado si existe', () async {
      when(() => mockRepository.getAuthenticatedUser())
          .thenAnswer((_) async => fakeUser);

      final result = await mockRepository.getAuthenticatedUser();

      expect(result, equals(fakeUser));
    });

    test('deberia retornar null si no hay usuario autenticado', () async {
      when(() => mockRepository.getAuthenticatedUser())
          .thenAnswer((_) async => null);

      final result = await mockRepository.getAuthenticatedUser();

      expect(result, isNull);
    });

    // --- resetPassword ---
    group('resetPassword', () {
      test('deberia enviar correo de recuperacion exitosamente', () async {
        when(() => mockRepository.resetPassword(any()))
            .thenAnswer((_) async {});

        await expectLater(
          mockRepository.resetPassword('test@email.com'),
          completes,
        );
        verify(() => mockRepository.resetPassword(any())).called(1);
      });

      test('deberia lanzar excepcion si el email no esta registrado', () async {
        when(() => mockRepository.resetPassword(any()))
            .thenThrow(FirebaseAuthException(code: 'user-not-found'));

        expect(
          () => mockRepository.resetPassword('noexiste@email.com'),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });
    // --- completeProfile ---
    group('completeProfile', () {
      test('deberia completar el perfil exitosamente', () async {
        when(() => mockRepository.completeProfile(
              originCountry: any(named: 'originCountry'),
              destinationCountry: any(named: 'destinationCountry'),
              age: any(named: 'age'),
            )).thenAnswer((_) async {});

        await expectLater(
          mockRepository.completeProfile(
            originCountry: 'Colombia',
            destinationCountry: 'España',
            age: 30,
          ),
          completes,
        );
      });

      test('deberia lanzar excepcion si faltan datos requeridos', () async {
        when(() => mockRepository.completeProfile(
              originCountry: any(named: 'originCountry'),
              destinationCountry: any(named: 'destinationCountry'),
              age: any(named: 'age'),
            )).thenThrow(Exception('Datos de perfil incompletos'));

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
