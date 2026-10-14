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

class MockEntityMobileRepository extends Mock
    implements EntityMobileRepository {}

void main() {
  late MockEntityWebRepository mockWebRepository;
  late MockEntityMobileRepository mockMobileRepository;
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
    mockMobileRepository = MockEntityMobileRepository();
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

  group('WEB', () {
    group('Registrar una entidad', () {
      late RegisterEntityUseCase useCase;

      setUp(() {
        useCase = RegisterEntityUseCase(mockWebRepository);
      });

      test('éxito - debe registrar la entidad', () async {
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
      }, tags: ['sprint_2']);

      test(
        'error - debe retornar Left(EntityCreationFailedFailure) al fallar',
        () async {
          when(() => mockWebRepository.registerEntity(
                    entity: any(named: 'entity'),
                    imagenBytes: any(named: 'imagenBytes'),
                    fileName: any(named: 'fileName'),
                  ))
              .thenAnswer(
                  (_) async => const Left(EntityCreationFailedFailure()));

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
        },
        tags: ['sprint_2'],
      );
    });

    group('Actualizar una entidad', () {
      late UpdateEntityUseCase useCase;

      setUp(() {
        useCase = UpdateEntityUseCase(mockWebRepository);
      });

      test('éxito - debe actualizar la entidad', () async {
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
      }, tags: ['sprint_2']);

      test(
        'error - debe retornar Left(EntityUpdateFailedFailure) al fallar',
        () async {
          when(() => mockWebRepository.updateEntity(
                    entity: any(named: 'entity'),
                    imagenBytes: any(named: 'imagenBytes'),
                    fileName: any(named: 'fileName'),
                  ))
              .thenAnswer((_) async => const Left(EntityUpdateFailedFailure()));

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
        },
        tags: ['sprint_2'],
      );
    });

    group('Eliminar una entidad', () {
      late DeleteEntityUseCase useCase;

      setUp(() {
        useCase = DeleteEntityUseCase(mockWebRepository);
      });

      test('éxito - debe eliminar la entidad', () async {
        when(() => mockWebRepository.deleteEntity('entity-001'))
            .thenAnswer((_) async => const Right(null));

        final result = await useCase('entity-001');

        expect(result, const Right(null));
        verify(() => mockWebRepository.deleteEntity('entity-001')).called(1);
      }, tags: ['sprint_2']);

      test(
        'error - debe retornar Left(EntityDeletionFailedFailure) al fallar',
        () async {
          when(() => mockWebRepository.deleteEntity(any())).thenAnswer(
              (_) async => const Left(EntityDeletionFailedFailure()));

          final result = await useCase('entity-001');

          expect(result, const Left(EntityDeletionFailedFailure()));
          verify(() => mockWebRepository.deleteEntity('entity-001')).called(1);
        },
        tags: ['sprint_2'],
      );
    });

    group('Obtener entidad por ID', () {
      late GetEntityByIdUseCase useCase;

      setUp(() {
        useCase = GetEntityByIdUseCase(mockWebRepository);
      });

      test('éxito - debe devolver la entidad por id', () async {
        when(() => mockWebRepository.getEntityById('entity-001'))
            .thenAnswer((_) async => Right(fakeEntity));

        final result = await useCase('entity-001');

        expect(result, Right(fakeEntity));
        verify(() => mockWebRepository.getEntityById('entity-001')).called(1);
      }, tags: ['sprint_2']);

      test(
        'error - debe retornar Left(EntityNotFoundFailure) si no existe la entidad',
        () async {
          when(() => mockWebRepository.getEntityById(any()))
              .thenAnswer((_) async => const Left(EntityNotFoundFailure()));

          final result = await useCase('entity-001');

          expect(result, const Left(EntityNotFoundFailure()));
          verify(() => mockWebRepository.getEntityById('entity-001')).called(1);
        },
        tags: ['sprint_2'],
      );
    });

    group('Obtener todas las entidades como Stream', () {
      late GetAllEntities2StreamUseCase useCase;

      setUp(() {
        useCase = GetAllEntities2StreamUseCase(mockWebRepository);
      });

      test('éxito - debe emitir una lista de entidades desde el Stream',
          () async {
        when(() => mockWebRepository.getAllEntites2())
            .thenAnswer((_) => Stream.value([fakeEntity]));

        final stream = useCase();

        await expectLater(stream, emits([fakeEntity]));
        verify(() => mockWebRepository.getAllEntites2()).called(1);
      }, tags: ['sprint_2']);

      test('error - debe emitir un error cuando falla el Stream', () async {
        when(() => mockWebRepository.getAllEntites2())
            .thenAnswer((_) => Stream.error(const EntityFetchFailedFailure()));

        final stream = useCase();

        await expectLater(stream, emitsError(isA<EntityFetchFailedFailure>()));
        verify(() => mockWebRepository.getAllEntites2()).called(1);
      }, tags: ['sprint_2']);
    });
  });

  group('MÓVIL', () {
    group('Obtener todas las entidades', () {
      late GetAllEntitiesUseCase useCase;

      setUp(() {
        useCase = GetAllEntitiesUseCase(mockMobileRepository);
      });

      test('éxito - debe devolver una lista de entidades', () async {
        when(() => mockMobileRepository.getAllEntities())
            .thenAnswer((_) async => Right([fakeEntity]));

        final result = await useCase();

        expect(result, Right([fakeEntity]));
        verify(() => mockMobileRepository.getAllEntities()).called(1);
      }, tags: ['spring_3']);

      test('error - debe retornar Left(EntityFetchFailedFailure) al fallar',
          () async {
        when(() => mockMobileRepository.getAllEntities())
            .thenAnswer((_) async => const Left(EntityFetchFailedFailure()));

        final result = await useCase();

        expect(result, const Left(EntityFetchFailedFailure()));
        verify(() => mockMobileRepository.getAllEntities()).called(1);
      }, tags: ['spring_3']);
    });

    group('Sincronizar todas las entidades desde Firebase', () {
      late SyncAllFromFirebaseUseCase useCase;

      setUp(() {
        useCase = SyncAllFromFirebaseUseCase(mockMobileRepository);
      });

      test('éxito - debe sincronizar todas las entidades correctamente',
          () async {
        when(() => mockMobileRepository.syncAllFromFirebase())
            .thenAnswer((_) async => const Right(null));

        final result = await useCase();

        expect(result, const Right(null));
        verify(() => mockMobileRepository.syncAllFromFirebase()).called(1);
      }, tags: ['spring_3']);

      test(
          'error - debe retornar Left(NetworkFailure) si falla la sincronización',
          () async {
        when(() => mockMobileRepository.syncAllFromFirebase())
            .thenAnswer((_) async => const Left(NetworkFailure()));

        final result = await useCase();

        expect(result, const Left(NetworkFailure()));
        verify(() => mockMobileRepository.syncAllFromFirebase()).called(1);
      }, tags: ['spring_3']);
    });
  });
}
