import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

class EntityModels extends EntityEntity {
  EntityModels({
    required super.id,
    required super.name,
    required super.description,
    required super.services,
    required super.address,
    required super.localitation,
    required super.phone,
    required super.imageUrl,
    super.averageRating = 0,
    super.totalReviews = 0,
    required super.schedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'services': services,
      'address': address,
      'localitation_latitude': localitation.latitude,
      'localitation_longitude': localitation.longitude,
      'phone': phone,
      'image_url': imageUrl,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'schedule': schedule,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory EntityModels.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EntityModels(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        services: (data['services'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        address: data['address'] ?? '',
        localitation: GeoPoint(
          data['localitation_latitude'] ?? 0.0,
          data['localitation_longitude'] ?? 0.0,
        ),
        phone: data['phone'] ?? '',
        imageUrl: data['image_url'] ?? '',
        averageRating: (data['average_rating'] as num?)?.toDouble() ?? 0,
        totalReviews: (data['total_reviews'] as int?) ?? 0,
        schedule: data['schedule'] ?? 'No definido');
  }

  /// Convierte Map de Sembast a EntityModels
  factory EntityModels.fromSembastMap(String id, Map<String, dynamic> map) {
    return EntityModels(
        id: id,
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        services: (map['services'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        address: map['address'] ?? '',
        localitation: GeoPoint(
          map['localitation_latitude'] ?? 0.0,
          map['localitation_longitude'] ?? 0.0,
        ),
        phone: map['phone'] ?? '',
        imageUrl: map['image_url'] ?? '',
        averageRating: (map['average_rating'] as num?)?.toDouble() ?? 0,
        totalReviews: (map['total_reviews'] as int?) ?? 0,
        schedule: map['schedule'] ?? 'No definido');
  }
}
