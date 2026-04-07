import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/entities/entity_entity.dart';

class EntityModels extends EntityEntity {
  EntityModels({
    required super.id,
    required super.name,
    required super.description,
    required super.services,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.phone,
    required super.serviceHours,
    required super.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'services': services,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'service_hours': serviceHours,
      'image_url': imageUrl,
    };
  }

  factory EntityModels.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EntityModels(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      services: data['services'] ?? [],
      address: data['address'] ?? '',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      phone: data['phone'] ?? '',
      serviceHours: data['service_hours'] ?? '',
      imageUrl: data['image_url'] ?? '',
    );
  }
}
