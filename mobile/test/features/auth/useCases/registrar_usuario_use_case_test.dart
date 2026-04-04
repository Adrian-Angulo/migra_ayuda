import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/registrar_usuario_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRerpository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRerpository mockRepository;
  late RegisterUserUseCase registerUserUseCase;

  setUp(
    () {
      mockRepository = MockAuthRerpository();
      registerUserUseCase = RegisterUserUseCase(mockRepository);
    },
  );

  final user = UserModel(
      name: 'Juan',
      lastname: 'Pérez',
      email: 'juan@example.com',
      password: 'password123',
      age: "30",
      destinationCountry: 'España',
      originCountry: 'México');

  test('deberia retornar Right(unit) cuando el registro es exitoso', () async {
    when(() => mockRepository.registerUser(user)).thenAnswer(
      (_) async => const Right(unit),
    );

    final result = await registerUserUseCase(user);

    expect(result, const Right(unit));
    verify(() => mockRepository.registerUser(user)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('deberia retornar EmailAlreadyInUseFailure cuando el correo ya existe',
      () async {
    when(() => mockRepository.registerUser(user)).thenAnswer(
      (_) async => const Left(EmailAlreadyInUseFailure()),
    );

    final result = await registerUserUseCase(user);

    expect(result, const Left(EmailAlreadyInUseFailure()));
    verify(() => mockRepository.registerUser(user)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

}
