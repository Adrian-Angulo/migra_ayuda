import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/failures/entity_failures.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_mobile_repository.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_web_repository.dart';
import 'package:migra_ayuda/features/entities/domain/usecases/entities_usecases.dart';
import 'package:mocktail/mocktail.dart';

class MockEntityWebRepository extends Mock implements EntityWebRepository {}

class MockEntityMoblieRepository extends Mock
    implements EntityMobileRepository {}

void main() {
  late MockEntityWebRepository mockWebRepository;
  late MockEntityMoblieRepository mockMobileRepository;
  late EntityEntity fakeEntity;
  late Uint8List fakeImageBytes;

  setUpAll(() {
    registerFallbackValue(
      const EntityEntity(
        id: 'fallback-id',
        name: 'Fallback Entity',
        description: 'Fallback description',
        services: [],
        address: 'Fallback address',
        localitation: GeoPoint(0, 0),
        phone: '0000000000',
        imageUrl: 'https://example.com/fallback.jpg',
        schedule: '24/7',
      ),
    );
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockWebRepository = MockEntityWebRepository();
    fakeImageBytes = Uint8List.fromList([0, 1, 2, 3]);
    fakeEntity = const EntityEntity(
      id: 'entity-001',
      name: 'Centro de Migrantes',
      description: 'Entidad de apoyo a migrantes',
      services: ['Salud', 'Legal'],
      address: 'Calle 123, Bogotá',
      localitation: GeoPoint(4.711, -74.072),
      phone: '3001234567',
      imageUrl: 'https://example.com/image.jpg',
      schedule: 'Lunes a Viernes 8am - 5pm',
    );
  });

  group('Register entity', () {
    late RegisterEntityUseCase useCase;

    setUp(() {
      useCase = RegisterEntityUseCase(mockWebRepository);
    });

    test(
      'éxito: debería registrar la entidad satisfactoriamente',
      () async {
        when(() => mockWebRepository.registerEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: 'imagen.jpg',
            )).thenAnswer((_) async => const Right(null));

        final result = await useCase(
          entity: fakeEntity,
          imagenBytes: fakeImageBytes,
          fileName: 'imagen.jpg',
        );

        expect(result, const Right(null));
        verify(() => mockWebRepository.registerEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: 'imagen.jpg',
            )).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );

    test(
      'error: debería retornar Left(EntityCreationFailedFailure) cuando falla el registro',
      () async {
        when(() => mockWebRepository.registerEntity(
              entity: any(named: 'entity'),
              imagenBytes: any(named: 'imagenBytes'),
              fileName: any(named: 'fileName'),
            )).thenAnswer(
          (_) async => const Left(EntityCreationFailedFailure()),
        );

        final result = await useCase(
          entity: fakeEntity,
          imagenBytes: fakeImageBytes,
          fileName: 'imagen.jpg',
        );

        expect(result, const Left(EntityCreationFailedFailure()));
        verify(() => mockWebRepository.registerEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: 'imagen.jpg',
            )).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );
  });

  group('Update entity', () {
    late UpdateEntityUseCase useCase;

    setUp(() {
      useCase = UpdateEntityUseCase(mockWebRepository);
    });

    test(
      'éxito: debería actualizar la entidad satisfactoriamente',
      () async {
        when(() => mockWebRepository.updateEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: 'imagen.jpg',
            )).thenAnswer((_) async => const Right(null));

        final result = await useCase(
          entity: fakeEntity,
          imagenBytes: fakeImageBytes,
          fileName: 'imagen.jpg',
        );

        expect(result, const Right(null));
        verify(() => mockWebRepository.updateEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: 'imagen.jpg',
            )).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );

    test(
      'error: debería retornar Left(EntityUpdateFailedFailure) cuando falla la actualización',
      () async {
        when(() => mockWebRepository.updateEntity(
              entity: any(named: 'entity'),
              imagenBytes: any(named: 'imagenBytes'),
              fileName: any(named: 'fileName'),
            )).thenAnswer(
          (_) async => const Left(EntityUpdateFailedFailure()),
        );

        final result = await useCase(
          entity: fakeEntity,
          imagenBytes: fakeImageBytes,
          fileName: 'imagen.jpg',
        );

        expect(result, const Left(EntityUpdateFailedFailure()));
        verify(() => mockWebRepository.updateEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: 'imagen.jpg',
            )).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );
  });

  group('DeleteEntityUseCase', () {
    late DeleteEntityUseCase useCase;

    setUp(() {
      useCase = DeleteEntityUseCase(mockWebRepository);
    });

    test(
      'éxito: debería eliminar la entidad satisfactoriamente',
      () async {
        when(() => mockWebRepository.deleteEntity('entity-001'))
            .thenAnswer((_) async => const Right(null));

        final result = await useCase('entity-001');

        expect(result, const Right(null));
        verify(() => mockWebRepository.deleteEntity('entity-001')).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );

    test(
      'error: debería retornar Left(EntityDeletionFailedFailure) cuando falla la eliminación',
      () async {
        when(() => mockWebRepository.deleteEntity(any())).thenAnswer(
          (_) async => const Left(EntityDeletionFailedFailure()),
        );

        final result = await useCase('entity-001');

        expect(result, const Left(EntityDeletionFailedFailure()));
        verify(() => mockWebRepository.deleteEntity('entity-001')).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );
  });

  group('GetAllEntitiesUseCase', () {
    late GetAllEntitiesUseCase useCase;

    setUp(() {
      useCase = GetAllEntitiesUseCase(mockMobileRepository);
    });

    test(
      'éxito: debería retornar la lista de entidades disponibles',
      () async {
        when(() => mockWebRepository.getAllEntities())
            .thenAnswer((_) async => Right([fakeEntity]));

        final result = await useCase();

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Debería retornar Right'),
          (entities) {
            expect(entities.length, 1);
            expect(entities.first.id, 'entity-001');
          },
        );
        verify(() => mockWebRepository.getAllEntities()).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );

    test(
      'error: debería retornar Left(EntityFetchFailedFailure) cuando falla la consulta de entidades',
      () async {
        when(() => mockWebRepository.getAllEntities()).thenAnswer(
          (_) async => const Left(EntityFetchFailedFailure()),
        );

        final result = await useCase();

        expect(result, const Left(EntityFetchFailedFailure()));
        verify(() => mockWebRepository.getAllEntities()).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );
  });

  group('GetEntityByIdUseCase', () {
    late GetEntityByIdUseCase useCase;

    setUp(() {
      useCase = GetEntityByIdUseCase(mockWebRepository);
    });

    test(
      'éxito: debería retornar la entidad correspondiente al ID consultado',
      () async {
        when(() => mockWebRepository.getEntityById('entity-001'))
            .thenAnswer((_) async => Right(fakeEntity));

        final result = await useCase('entity-001');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Debería retornar Right'),
          (entity) {
            expect(entity.id, 'entity-001');
            expect(entity.name, 'Centro de Migrantes');
          },
        );
        verify(() => mockWebRepository.getEntityById('entity-001')).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );

    test(
      'error: debería retornar Left(EntityNotFoundFailure) cuando la entidad no existe',
      () async {
        when(() => mockWebRepository.getEntityById(any())).thenAnswer(
          (_) async => const Left(EntityNotFoundFailure()),
        );

        final result = await useCase('entity-001');

        expect(result, const Left(EntityNotFoundFailure()));
        verify(() => mockWebRepository.getEntityById('entity-001')).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );
  });

  group('GetAllEntities2StreamUseCase', () {
    late GetAllEntities2StreamUseCase useCase;

    setUp(() {
      useCase = GetAllEntities2StreamUseCase(mockWebRepository);
    });

    test(
      'éxito: debería emitir la lista de entidades desde el stream',
      () async {
        when(() => mockWebRepository.getAllEntites2())
            .thenAnswer((_) => Stream.value([fakeEntity]));

        final stream = useCase();

        await expectLater(stream, emits([fakeEntity]));
        verify(() => mockWebRepository.getAllEntites2()).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );

    test(
      'error: debería emitir un error cuando el stream del repositorio falla',
      () async {
        when(() => mockWebRepository.getAllEntites2())
            .thenAnswer((_) => Stream.error(const EntityFetchFailedFailure()));

        final stream = useCase();

        await expectLater(stream, emitsError(isA<EntityFetchFailedFailure>()));
        verify(() => mockWebRepository.getAllEntites2()).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );
  });

  group('SyncAllFromFirebaseUseCase', () {
    late SyncAllFromFirebaseUseCase useCase;

    setUp(() {
      useCase = SyncAllFromFirebaseUseCase(mockWebRepository);
    });

    test(
      'éxito: debería sincronizar todas las entidades satisfactoriamente',
      () async {
        when(() => mockWebRepository.syncAllFromFirebase())
            .thenAnswer((_) async => const Right(null));

        final result = await useCase();

        expect(result, const Right(null));
        verify(() => mockWebRepository.syncAllFromFirebase()).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );

    test(
      'error: debería retornar Left(NetworkFailure) si falla la sincronización',
      () async {
        when(() => mockWebRepository.syncAllFromFirebase()).thenAnswer(
          (_) async => const Left(NetworkFailure()),
        );

        final result = await useCase();

        expect(result, const Left(NetworkFailure()));
        verify(() => mockWebRepository.syncAllFromFirebase()).called(1);
        verifyNoMoreInteractions(mockWebRepository);
      },
    );
  });
}
