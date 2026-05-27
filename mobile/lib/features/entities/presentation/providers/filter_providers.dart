import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/get_all_entites_notifier.dart';

final entidadesProvider = Provider(
  (ref) {
    final entities = [
      const EntityEntity(
        id: '1',
        name: 'Centro de Apoyo Legal',
        description: 'Asesoría jurídica gratuita para migrantes.',
        services: ['Legal'],
        address: 'Calle 10 #45-20, Bogotá',
        localitation: GeoPoint(4.7110, -74.0721),
        phone: '+57 300 123 4567',
        serviceHours: 'Lun-Vie 8am-5pm',
        imageUrl: 'https://example.com/images/legal.jpg',
      ),
      const EntityEntity(
        id: '2',
        name: 'Clínica Migrante',
        description: 'Atención médica básica y orientación en salud.',
        services: ['Salud'],
        address: 'Carrera 7 #32-10, Bogotá',
        localitation: GeoPoint(4.6351, -74.0703),
        phone: '+57 301 987 6543',
        serviceHours: 'Lun-Sáb 7am-6pm',
        imageUrl: 'https://example.com/images/salud.jpg',
      ),
      const EntityEntity(
        id: '3',
        name: 'Fundación Hogar Seguro',
        description: 'Alojamiento temporal y orientación en vivienda.',
        services: ['Vivienda'],
        address: 'Avenida 68 #12-30, Bogotá',
        localitation: GeoPoint(4.6482, -74.1002),
        phone: '+57 302 456 7890',
        serviceHours: 'Lun-Dom 24h',
        imageUrl: 'https://example.com/images/vivienda.jpg',
      ),
      const EntityEntity(
        id: '4',
        name: 'Bolsa de Empleo Migrante',
        description: 'Intermediación laboral y capacitación para el trabajo.',
        services: ['Trabajo'],
        address: 'Calle 26 #59-41, Bogotá',
        localitation: GeoPoint(4.6575, -74.1059),
        phone: '+57 303 321 0987',
        serviceHours: 'Lun-Vie 9am-4pm',
        imageUrl: 'https://example.com/images/trabajo.jpg',
      ),
      const EntityEntity(
        id: '5',
        name: 'Escuela Inclusiva',
        description:
            'Programas educativos y de integración para niños migrantes.',
        services: ['Educación'],
        address: 'Transversal 93 #45-67, Bogotá',
        localitation: GeoPoint(4.7260, -74.0543),
        phone: '+57 304 654 3210',
        serviceHours: 'Lun-Vie 7am-3pm',
        imageUrl: 'https://example.com/images/educacion.jpg',
      ),
      const EntityEntity(
        id: '6',
        name: 'Centro Integral Migrante',
        description: 'Servicios integrales de apoyo legal, salud y trabajo.',
        services: ['Legal', 'Salud', 'Trabajo'],
        address: 'Calle 72 #10-07, Bogotá',
        localitation: GeoPoint(4.6697, -74.0551),
        phone: '+57 305 789 0123',
        serviceHours: 'Lun-Sáb 8am-6pm',
        imageUrl: 'https://example.com/images/integral.jpg',
      ),
    ];

    return entities;
  },
);
final seletedFilterProvider = StateProvider<String>(
  (ref) => 'Todos',
);
final listaEntidades = Provider<AsyncValue<List<EntityEntity>>>(
  (ref) {
    final entitiesAsync = ref.watch(getAllEntitiesNotifierProvider);
    final seletedService = ref.watch(seletedFilterProvider);

    return entitiesAsync.whenData(
      (data) {
        if (seletedService == 'Todos') return data;
        return data
            .where((enty) => enty.services.contains(seletedService))
            .toList();
      },
    );
    
  },
);
