import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/failures/users_failures.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';
import 'package:migra_ayuda/features/users/domain/usecases/complete_profile_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/create_user_profile_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/get_all_users_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/get_user_profile_usecase.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;
  late Migrant fakeMigrant;

  setUpAll(() {
    fakeMigrant = Migrant(
      id: 'user-001',
      name: 'Juan Perez',
      email: 'juan@example.com',
      originCountry: 'Colombia',
      destinationCountry: 'España',
      age: '28',
      role: 'Migrante',
      profileComplete: true,
    );
    registerFallbackValue(fakeMigrant);
  });

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('Completar perfil', () {
    late CompleteProfileUseCase useCase;

    setUp(() {
      useCase = CompleteProfileUseCase(mockUserRepository);
    });

    test('éxito - debe completar el perfil satisfactoriamente', () async {
      when(() => mockUserRepository.completeProfile(
            id: fakeMigrant.id,
            originCountry: fakeMigrant.originCountry,
            destinationCountry: fakeMigrant.destinationCountry,
            age: 28,
          )).thenAnswer((_) async => const Right(null));

      final result = await useCase(
        id: fakeMigrant.id,
        originCountry: fakeMigrant.originCountry,
        destinationCountry: fakeMigrant.destinationCountry,
        age: 28,
      );

      expect(result, const Right(null));
      verify(() => mockUserRepository.completeProfile(
            id: fakeMigrant.id,
            originCountry: fakeMigrant.originCountry,
            destinationCountry: fakeMigrant.destinationCountry,
            age: 28,
          )).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    }, tags: ['sprint_1']);

    test(
        'error - debe retornar Left(UserProfileUpdateFailedFailure) cuando ocurre un fallo',
        () async {
      when(() => mockUserRepository.completeProfile(
            id: any(named: 'id'),
            originCountry: any(named: 'originCountry'),
            destinationCountry: any(named: 'destinationCountry'),
            age: any(named: 'age'),
          )).thenAnswer(
        (_) async => const Left(UserProfileUpdateFailedFailure()),
      );

      final result = await useCase(
        id: fakeMigrant.id,
        originCountry: fakeMigrant.originCountry,
        destinationCountry: fakeMigrant.destinationCountry,
        age: 28,
      );

      expect(result, const Left(UserProfileUpdateFailedFailure()));
      verify(() => mockUserRepository.completeProfile(
            id: fakeMigrant.id,
            originCountry: fakeMigrant.originCountry,
            destinationCountry: fakeMigrant.destinationCountry,
            age: 28,
          )).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    }, tags: ['sprint_1']);
  });

  group('Crear perfil de usuario', () {
    late CreateUserProfileUseCase useCase;

    setUp(() {
      useCase = CreateUserProfileUseCase(mockUserRepository);
    });

    test(
      'éxito - debe crear el perfil de usuario satisfactoriamente',
      () async {
        when(() => mockUserRepository.createUser(fakeMigrant))
            .thenAnswer((_) async => const Right(null));

        final result = await useCase(fakeMigrant);

        expect(result, const Right(null));
        verify(() => mockUserRepository.createUser(fakeMigrant)).called(1);
        verifyNoMoreInteractions(mockUserRepository);
      },
    );

    test(
        'error - debe retornar Left(UserProfileCreationFailedFailure) cuando falla la creación',
        () async {
      when(() => mockUserRepository.createUser(any())).thenAnswer(
          (_) async => const Left(UserProfileCreationFailedFailure()));

      final result = await useCase(fakeMigrant);

      expect(result, const Left(UserProfileCreationFailedFailure()));
      verify(() => mockUserRepository.createUser(fakeMigrant)).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    }, tags: ['sprint_1']);
  });

  group('Obtener todos los usuarios', () {
    late GetAllUsersUseCase useCase;

    setUp(() {
      useCase = GetAllUsersUseCase(mockUserRepository);
    });

    test(
        'éxito - debe emitir la lista de migrantes desde el stream correctamente',
        () async {
      final fakeUserList = [fakeMigrant];
      when(() => mockUserRepository.getAllUsers())
          .thenAnswer((_) => Stream.value(fakeUserList));

      final resultStream = useCase();

      await expectLater(resultStream, emits(fakeUserList));
      verify(() => mockUserRepository.getAllUsers()).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    }, tags: ['sprint_1']);

    test('error - debe emitir un error cuando el stream del repositorio falla',
        () async {
      final exception = Exception('Error al obtener la lista de usuarios');
      when(() => mockUserRepository.getAllUsers())
          .thenAnswer((_) => Stream.error(exception));

      final resultStream = useCase();

      await expectLater(resultStream, emitsError(isA<Exception>()));
      verify(() => mockUserRepository.getAllUsers()).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    }, tags: ['sprint_1']);
  });

  group('Obtener Perfil de Usuario', () {
    late GetUserProfileUseCase useCase;

    setUp(() {
      useCase = GetUserProfileUseCase(mockUserRepository);
    });

    test('éxito - debe retornar el perfil del migrante cuando existe',
        () async {
      when(() => mockUserRepository.getUserById(fakeMigrant.id))
          .thenAnswer((_) async => Right(fakeMigrant));

      final result = await useCase(fakeMigrant.id);

      expect(result, Right(fakeMigrant));
      verify(() => mockUserRepository.getUserById(fakeMigrant.id)).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    }, tags: ['sprint_1']);

    test(
        'error - debe retornar Left(UserNotFoundFailure) cuando el usuario no existe',
        () async {
      const fakeInvalidId = 'non-existent-id';
      when(() => mockUserRepository.getUserById(fakeInvalidId))
          .thenAnswer((_) async => const Left(UserNotFoundFailure()));

      final result = await useCase(fakeInvalidId);

      expect(result, const Left(UserNotFoundFailure()));
      verify(() => mockUserRepository.getUserById(fakeInvalidId)).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    }, tags: ['sprint_1']);
  });
}
