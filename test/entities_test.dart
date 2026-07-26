import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockEntityRepository extends Mock implements EntityRepository {}

void main() {
  group('Entities', () {
    late MockEntityRepository mockRepository;
    late EntityEntity fakeEntity;
    late Uint8List fakeImageBytes;

    setUp(() {
      mockRepository = MockEntityRepository();
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

    // =========================================================================
    // getAllEntities
    // =========================================================================

    group('getAllEntities', () {
      test('deberia retornar Right con lista de entidades', () async {
        // Simular respuesta exitosa del repositorio con una lista de entidades
        when(() => mockRepository.getAllEntities())
            .thenAnswer((_) async => Right([fakeEntity]));

        // Ejecutar el método a probar
        final result = await mockRepository.getAllEntities();

        // Verificar que el resultado sea exitoso y contenga los datos esperados
        result.fold(
          (error) => fail('Se esperaba Right pero se obtuvo Left: $error'),
          (entities) {
            expect(entities, isA<List<EntityEntity>>());
            expect(entities.length, 1);
            expect(entities.first.id, 'entity-001');
          },
        );
        // Verificar que el método fue llamado 1 vez
        verify(() => mockRepository.getAllEntities()).called(1);
      });

      test('deberia retornar Left con mensaje de error cuando falla', () async {
        // Simular un fallo en el repositorio retornando un mensaje de error
        when(() => mockRepository.getAllEntities())
            .thenAnswer((_) async => const Left('Error al obtener entidades'));

        final result = await mockRepository.getAllEntities();

        // Verificar que retorne el fallo esperado
        result.fold(
          (error) => expect(error, 'Error al obtener entidades'),
          (_) => fail('Se esperaba Left pero se obtuvo Right'),
        );
      });
    });

    // =========================================================================
    // getEntityById
    // =========================================================================

    group('getEntityById', () {
      test('deberia retornar Right con la entidad cuando el ID existe',
          () async {
        // Simular obtención exitosa de una entidad por su ID
        when(() => mockRepository.getEntityById('entity-001'))
            .thenAnswer((_) async => Right(fakeEntity));

        final result = await mockRepository.getEntityById('entity-001');

        // Validar que la entidad obtenida coincida con los datos simulados
        result.fold(
          (error) => fail('Se esperaba Right pero se obtuvo Left: $error'),
          (entity) {
            expect(entity.id, 'entity-001');
            expect(entity.name, 'Centro de Migrantes');
          },
        );
        verify(() => mockRepository.getEntityById('entity-001')).called(1);
      });

      test('deberia retornar Left cuando el ID no existe', () async {
        // Simular fallo al buscar una entidad con ID inexistente
        when(() => mockRepository.getEntityById(any()))
            .thenAnswer((_) async => const Left('Entidad no encontrada'));

        final result = await mockRepository.getEntityById('id-inexistente');

        // Validar que devuelva el mensaje de error correspondiente
        result.fold(
          (error) => expect(error, 'Entidad no encontrada'),
          (_) => fail('Se esperaba Left pero se obtuvo Right'),
        );
      });
    });

    // =========================================================================
    // registerEntity
    // =========================================================================

    group('registerEntity', () {
      test('deberia retornar Right(Unit) en registro exitoso', () async {
        // Simular registro exitoso de una nueva entidad
        when(() => mockRepository.registerEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: 'imagen.jpg',
            )).thenAnswer((_) async => const Right(unit));

        final result = await mockRepository.registerEntity(
          entity: fakeEntity,
          imagenBytes: fakeImageBytes,
          fileName: 'imagen.jpg',
        );

        // Validar que el resultado sea exitoso (Right(unit))
        result.fold(
          (error) => fail('Se esperaba Right pero se obtuvo Left: $error'),
          (success) => expect(success, unit),
        );
        verify(() => mockRepository.registerEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: 'imagen.jpg',
            )).called(1);
      });

      test('deberia retornar Left si hay error al registrar', () async {
        // Simular error al intentar registrar la entidad
        when(() => mockRepository.registerEntity(
                  entity: fakeEntity,
                  imagenBytes: fakeImageBytes,
                  fileName: any(named: 'fileName'),
                ))
            .thenAnswer((_) async => const Left('Error al registrar entidad'));

        final result = await mockRepository.registerEntity(
          entity: fakeEntity,
          imagenBytes: fakeImageBytes,
          fileName: 'imagen.jpg',
        );

        // Validar que devuelva el mensaje de error de registro
        result.fold(
          (error) => expect(error, 'Error al registrar entidad'),
          (_) => fail('Se esperaba Left pero se obtuvo Right'),
        );
      });
    });

    // =========================================================================
    // updateEntity
    // =========================================================================

    group('updateEntity', () {
      test('deberia retornar Right(Unit) en actualizacion exitosa', () async {
        // Simular actualización exitosa de la entidad
        when(() => mockRepository.updateEntity(
              entity: fakeEntity,
              imagenBytes: any(named: 'imagenBytes'),
              fileName: any(named: 'fileName'),
            )).thenAnswer((_) async => const Right(unit));

        final result = await mockRepository.updateEntity(entity: fakeEntity);

        // Validar respuesta exitosa
        result.fold(
          (error) => fail('Se esperaba Right pero se obtuvo Left: $error'),
          (success) => expect(success, unit),
        );
        verify(() => mockRepository.updateEntity(
              entity: fakeEntity,
            )).called(1);
      });

      test('deberia retornar Left si hay error al actualizar', () async {
        // Simular fallo durante la actualización de la entidad
        when(() => mockRepository.updateEntity(
                  entity: fakeEntity,
                  imagenBytes: any(named: 'imagenBytes'),
                  fileName: any(named: 'fileName'),
                ))
            .thenAnswer((_) async => const Left('Error al actualizar entidad'));

        final result = await mockRepository.updateEntity(entity: fakeEntity);

        // Validar mensaje de error
        result.fold(
          (error) => expect(error, 'Error al actualizar entidad'),
          (_) => fail('Se esperaba Left pero se obtuvo Right'),
        );
      });
    });

    // =========================================================================
    // deleteEntity
    // =========================================================================

    group('deleteEntity', () {
      test('deberia retornar Right(Unit) en eliminacion exitosa', () async {
        // Simular eliminación exitosa de la entidad por ID
        when(() => mockRepository.deleteEntity('entity-001'))
            .thenAnswer((_) async => const Right(unit));

        final result = await mockRepository.deleteEntity('entity-001');

        // Validar que retorne confirmación exitosa (unit)
        result.fold(
          (error) => fail('Se esperaba Right pero se obtuvo Left: $error'),
          (success) => expect(success, unit),
        );
        verify(() => mockRepository.deleteEntity('entity-001')).called(1);
      });

      test('deberia retornar Left si hay error al eliminar', () async {
        // Simular error al intentar eliminar la entidad
        when(() => mockRepository.deleteEntity(any()))
            .thenAnswer((_) async => const Left('Error al eliminar entidad'));

        final result = await mockRepository.deleteEntity('entity-001');

        // Validar mensaje de error recibido
        result.fold(
          (error) => expect(error, 'Error al eliminar entidad'),
          (_) => fail('Se esperaba Left pero se obtuvo Right'),
        );
      });
    });
  });
}
