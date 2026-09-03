import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
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


    // getAllEntities


    group('getAllEntities', () {
      test('deberia retornar lista de entidades cuando es exitoso', () async {
        when(() => mockRepository.getAllEntities())
            .thenAnswer((_) async => [fakeEntity]);

        final result = await mockRepository.getAllEntities();

        expect(result, isA<List<EntityEntity>>());
        expect(result.length, 1);
        expect(result.first.id, 'entity-001');
        verify(() => mockRepository.getAllEntities()).called(1);
      });

      test('deberia lanzar excepcion cuando falla', () async {
        when(() => mockRepository.getAllEntities())
            .thenThrow(Exception('Error al obtener entidades'));

        expect(
          () async => await mockRepository.getAllEntities(),
          throwsA(isA<Exception>()),
        );
      });
    });


    // getEntityById


    group('getEntityById', () {
      test('deberia retornar la entidad cuando el ID existe', () async {
        when(() => mockRepository.getEntityById('entity-001'))
            .thenAnswer((_) async => fakeEntity);

        final result = await mockRepository.getEntityById('entity-001');
        expect(result.id, 'entity-001');
        expect(result.name, 'Centro de Migrantes');

        verify(() => mockRepository.getEntityById('entity-001')).called(1);
      });

      test('deberia lanzar excepcion cuando el ID no existe', () async {
        when(() => mockRepository.getEntityById(any()))
            .thenThrow(Exception('Entidad no encontrada'));

        expect(
          () async => await mockRepository.getEntityById('id-inexistente'),
          throwsA(isA<Exception>()),
        );
      });
    });

    // registerEntity


    group('registerEntity', () {
      test('deberia retornar registro exitoso', () async {
        var called = false;
        when(() => mockRepository.registerEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: 'imagen.jpg',
            )).thenAnswer((_) async {
          called = true;
        });

        await mockRepository.registerEntity(
          entity: fakeEntity,
          imagenBytes: fakeImageBytes,
          fileName: 'imagen.jpg',
        );

        expect(called, isTrue);
        verify(() => mockRepository.registerEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: 'imagen.jpg',
            )).called(1);
      });

      test('deberia lanzar excepcion si hay error al registrar', () async {
        when(() => mockRepository.registerEntity(
              entity: fakeEntity,
              imagenBytes: fakeImageBytes,
              fileName: any(named: 'fileName'),
            )).thenThrow(Exception('Error al registrar entidad'));

        expect(
          () async => await mockRepository.registerEntity(
            entity: fakeEntity,
            imagenBytes: fakeImageBytes,
            fileName: 'imagen.jpg',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });


    // updateEntity


    group('updateEntity', () {
      test('deberia realizar la actualizacion de forma exitosa', () async {
        var called = false;
        when(() => mockRepository.updateEntity(
              entity: fakeEntity,
              imagenBytes: any(named: 'imagenBytes'),
              fileName: any(named: 'fileName'),
            )).thenAnswer((_) async {
          called = true;
        });

        await mockRepository.updateEntity(entity: fakeEntity);

        expect(called, isTrue);
        verify(() => mockRepository.updateEntity(
              entity: fakeEntity,
            )).called(1);
      });

      test('deberia lanzar excepcion si hay error al actualizar', () async {
        when(() => mockRepository.updateEntity(
              entity: fakeEntity,
              imagenBytes: any(named: 'imagenBytes'),
              fileName: any(named: 'fileName'),
            )).thenThrow(Exception('Error al actualizar entidad'));

        expect(
          () async => await mockRepository.updateEntity(entity: fakeEntity),
          throwsA(isA<Exception>()),
        );
      });
    });

    // deleteEntity

    group('deleteEntity', () {
      test('deberia realizar la eliminacion de forma exitosa', () async {
        var called = false;
        when(() => mockRepository.deleteEntity('entity-001'))
            .thenAnswer((_) async {
          called = true;
        });

        await mockRepository.deleteEntity('entity-001');

        expect(called, isTrue);
        verify(() => mockRepository.deleteEntity('entity-001')).called(1);
      });

      test('deberia lanzar excepcion si hay error al eliminar', () async {
        when(() => mockRepository.deleteEntity(any()))
            .thenThrow(Exception('Error al eliminar entidad'));

        expect(
          () async => await mockRepository.deleteEntity('entity-001'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
