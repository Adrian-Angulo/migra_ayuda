import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/utils/format/time_formatter.dart';
import 'package:migra_ayuda/core/utils/utils.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';

void main() {
  final csvConverter = Csv(fieldDelimiter: ';');

  group('Pruebas Unitarias - HU-WEB-09: Exportación de Datos en Formato CSV', () {
    test('debería estructurar y codificar correctamente los datos de actividades de auditoría a CSV con delimitador punto y coma (;)', () {
      // Arrange (Preparar datos)
      final audit1 = AuditEntity(
        id: 'aud-1',
        idUser: 'usr-1',
        nombre: 'Carlos Mendoza',
        correo: 'carlos@example.com',
        pais: 'Perú',
        accion: 'LOGIN',
        metadata: {'platform': 'Android'},
        createdAt: DateTime(2026, 10, 24, 10, 30),
      );

      final headers = const [
        'Nombre',
        'Correo',
        'País',
        'Acción',
        'Detalle',
        'Fecha',
      ];

      final rows = [
        [
          audit1.nombre,
          audit1.correo,
          audit1.pais,
          audit1.accion,
          Utils.formatMetadata(audit1.metadata),
          TimeFormatter.formatShortDate(audit1.createdAt),
        ],
      ];

      // Act (Ejecutar codificación)
      final csvResult = csvConverter.encode([headers, ...rows]);

      // Assert (Verificar formato y contenido)
      expect(csvResult, contains('Nombre;Correo;País;Acción;Detalle;Fecha'));
      expect(csvResult, contains('Carlos Mendoza;carlos@example.com;Perú;LOGIN;Android'));
      expect(csvResult, contains(TimeFormatter.formatShortDate(audit1.createdAt)));
    });

    test('debería estructurar y codificar correctamente los registros de usuarios migrantes a CSV', () {
      // Arrange
      final user = Migrant(
        id: 'usr-001',
        name: 'Maria Gomez',
        email: 'maria@example.com',
        role: 'migrant',
        age: '28',
        originCountry: 'Venezuela',
        destinationCountry: 'Chile',
        createdAt: DateTime(2026, 9, 15, 8, 0),
      );

      final headers = const [
        'Nombre',
        'Correo',
        'Rol',
        'Edad',
        'País de origen',
        'País de destino',
        'Fecha de registro',
      ];

      final rows = [
        [
          user.name,
          user.email,
          user.role,
          user.age,
          user.originCountry,
          user.destinationCountry,
          TimeFormatter.formatShortDate(user.createdAt),
        ],
      ];

      // Act
      final csvResult = csvConverter.encode([headers, ...rows]);

      // Assert
      expect(csvResult, contains('Nombre;Correo;Rol;Edad;País de origen;País de destino;Fecha de registro'));
      expect(csvResult, contains('Maria Gomez;maria@example.com;migrant;28;Venezuela;Chile'));
    });

    test('debería estructurar y codificar correctamente entidades de apoyo a CSV', () {
      // Arrange
      const entity = EntityEntity(
        id: 'ent-001',
        name: 'Comedor Solidario',
        address: 'Av. Las Palmas 123',
        phone: '+51999888777',
        services: ['Alimentación', 'Orientación Legal'],
        schedule: '08:00 - 17:00',
        description: 'Centro de apoyo integral',
        imageUrl: 'https://example.com/photo.jpg',
        localitation: GeoPoint(-12.04, -77.03),
      );

      final headers = const [
        'Nombre',
        'Dirección',
        'Teléfono',
        'Servicios',
        'Horario',
        'Descripción',
      ];

      final rows = [
        [
          entity.name,
          entity.address,
          entity.phone,
          entity.services.join(', '),
          entity.schedule,
          entity.description,
        ],
      ];

      // Act
      final csvResult = csvConverter.encode([headers, ...rows]);

      // Assert
      expect(csvResult, contains('Nombre;Dirección;Teléfono;Servicios;Horario;Descripción'));
      expect(csvResult, contains('Comedor Solidario;Av. Las Palmas 123;+51999888777;Alimentación, Orientación Legal;08:00 - 17:00;Centro de apoyo integral'));
    });
  });
}
