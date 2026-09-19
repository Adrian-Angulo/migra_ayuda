import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';
import 'package:migra_ayuda/features/users/domain/usecases/complete_profile_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/create_user_profile_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/get_all_users_usecase.dart';
import 'package:migra_ayuda/features/users/domain/usecases/get_user_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

/// Mock del repositorio de usuarios
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  final fakeMigrant = Migrant(
    id: 'user-id-123',
    name: 'Juan Perez',
    email: 'juan@example.com',
    originCountry: 'Colombia',
    destinationCountry: 'España',
    age: '28',
    role: 'Migrante',
    profileComplete: true,
  );

  setUpAll(() {
    registerFallbackValue(fakeMigrant);
  });

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('CompleteProfileUseCase', () {
    late CompleteProfileUseCase useCase;

    setUp(() {
      useCase = CompleteProfileUseCase(mockUserRepository);
    });

    test(
      'éxito: debería completar el perfil satisfactoriamente',
      () async {
        when(() => mockUserRepository.completeProfile(
              id: 'user-id-123',
              originCountry: 'Colombia',
              destinationCountry: 'España',
              age: 28,
            )).thenAnswer((_) async => const Right(null));

        final result = await useCase(
          id: 'user-id-123',
          originCountry: 'Colombia',
          destinationCountry: 'España',
          age: 28,
        );

        expect(result, const Right(null));
        verify(() => mockUserRepository.completeProfile(
              id: 'user-id-123',
              originCountry: 'Colombia',
              destinationCountry: 'España',
              age: 28,
            )).called(1);
        verifyNoMoreInteractions(mockUserRepository);
      },
    );

    test(
      'error: debería retornar Error cuando falla la actualización del perfil',
      () async {
        // Arrange
        when(() => mockUserRepository.completeProfile(
              id: any(named: 'id'),
              originCountry: any(named: 'originCountry'),
              destinationCountry: any(named: 'destinationCountry'),
              age: any(named: 'age'),
            )).thenAnswer(
          (_) async => const Left(UserProfileUpdateFailedFailure()),
        );

        // Act
        final result = await useCase(
          id: 'user-id-123',
          originCountry: 'Colombia',
          destinationCountry: 'España',
          age: 28,
        );

        // Assert
        expect(result, const Left(UserProfileUpdateFailedFailure()));
        verify(() => mockUserRepository.completeProfile(
              id: 'user-id-123',
              originCountry: 'Colombia',
              destinationCountry: 'España',
              age: 28,
            )).called(1);
        verifyNoMoreInteractions(mockUserRepository);
      },
    );
  });

  group('CreateUserProfileUseCase', () {
    late CreateUserProfileUseCase useCase;

    setUp(() {
      useCase = CreateUserProfileUseCase(mockUserRepository);
    });

    test(
      'éxito: debería crear el perfil de usuario satisfactoriamente.',
      () async {
        // Arrange
        when(() => mockUserRepository.createUser(fakeMigrant))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(fakeMigrant);

        // Assert
        expect(result, const Right(null));
        verify(() => mockUserRepository.createUser(fakeMigrant)).called(1);
        verifyNoMoreInteractions(mockUserRepository);
      },
    );

    test(
      'error: debería retornar UserProfileCreationFailedFailure cuando falla la creación del perfil',
      () async {
        // Arrange
        when(() => mockUserRepository.createUser(any())).thenAnswer(
          (_) async => const Left(UserProfileCreationFailedFailure()),
        );

        // Act
        final result = await useCase(fakeMigrant);

        // Assert
        expect(result, const Left(UserProfileCreationFailedFailure()));
        verify(() => mockUserRepository.createUser(fakeMigrant)).called(1);
        verifyNoMoreInteractions(mockUserRepository);
      },
    );
  });

  group('GetAllUsersUseCase', () {
    late GetAllUsersUseCase useCase;

    setUp(() {
      useCase = GetAllUsersUseCase(mockUserRepository);
    });

    test(
      'éxito: debería emitir la lista de usuarios migrantes desde el stream',
      () async {
        // Arrange
        final usersList = [fakeMigrant];
        when(() => mockUserRepository.getAllUsers())
            .thenAnswer((_) => Stream.value(usersList));

        // Act
        final stream = useCase();

        // Assert
        await expectLater(stream, emits(usersList));
        verify(() => mockUserRepository.getAllUsers()).called(1);
        verifyNoMoreInteractions(mockUserRepository);
      },
    );

    test(
      'error: debería emitir un error cuando el stream del repositorio falla',
      () async {
        // Arrange
        final exception = Exception('Error al obtener la lista de usuarios');
        when(() => mockUserRepository.getAllUsers())
            .thenAnswer((_) => Stream.error(exception));

        // Act
        final stream = useCase();

        // Assert
        await expectLater(stream, emitsError(isA<Exception>()));
        verify(() => mockUserRepository.getAllUsers()).called(1);
        verifyNoMoreInteractions(mockUserRepository);
      },
    );
  });

  group('GetUserProfileUseCase', () {
    late GetUserProfileUseCase useCase;

    setUp(() {
      useCase = GetUserProfileUseCase(mockUserRepository);
    });

    test(
      'éxito: debería retornar el perfil del migrante cuando existe en el repositorio',
      () async {
        // Arrange
        when(() => mockUserRepository.getUserById('user-id-123'))
            .thenAnswer((_) async => Right(fakeMigrant));

        // Act
        final result = await useCase('user-id-123');

        // Assert
        expect(result, Right(fakeMigrant));
        verify(() => mockUserRepository.getUserById('user-id-123')).called(1);
        verifyNoMoreInteractions(mockUserRepository);
      },
    );

    test(
      'error: debería retornar UserNotFoundFailure cuando el usuario no existe',
      () async {
        // Arrange
        when(() => mockUserRepository.getUserById('inexistent-id'))
            .thenAnswer((_) async => const Left(UserNotFoundFailure()));

        // Act
        final result = await useCase('inexistent-id');

        // Assert
        expect(result, const Left(UserNotFoundFailure()));
        verify(() => mockUserRepository.getUserById('inexistent-id')).called(1);
        verifyNoMoreInteractions(mockUserRepository);
      },
    );
  });
}
