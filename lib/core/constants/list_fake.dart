import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

const listaEntityFake = [
  EntityEntity(
    id: '1',
    name: 'Centro Pasto',
    description: 'Centro de la ciudad de Pasto',
    services: ['Atención general'],
    address: 'Centro, Pasto',
    localitation: GeoPoint(1.2136, -77.2811),
    phone: '000-000-0000',
    imageUrl: '',
    schedule: 'Lunes a Viernes 8am - 5pm',
  ),
  EntityEntity(
    id: '2',
    name: 'Universidad de Nariño',
    description: 'Universidad pública de Nariño',
    services: ['Educación superior'],
    address: 'Torobajo, Pasto',
    localitation: GeoPoint(1.2200, -77.2850),
    phone: '000-000-0001',
    imageUrl: '',
    schedule: 'Lunes a Viernes 7am - 6pm',
  ),
  EntityEntity(
    id: '3',
    name: 'Hospital Departamental',
    description: 'Hospital departamental de Nariño',
    services: ['Urgencias', 'Consulta externa'],
    address: 'Av. Los Estudiantes, Pasto',
    localitation: GeoPoint(1.2080, -77.2750),
    phone: '000-000-0002',
    imageUrl: '',
    schedule: 'Lunes a Domingo 24 horas',
  ),
];
