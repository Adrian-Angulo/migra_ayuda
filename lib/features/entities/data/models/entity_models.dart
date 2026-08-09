import 'package:cloud_firestore/cloud_firestore.dart';

class EntityModels {
  final String id;
  final String name;
  final String description;
  final List<String> services;
  final String address;
  final GeoPoint localitation;
  final String phone;
  final String imageUrl;
  final double averageRating;
  final int totalReviews;
  final String schedule;

  EntityModels({
    required this.id,
    required this.name,
    required this.description,
    required this.services,
    required this.address,
    required this.localitation,
    required this.phone,
    required this.imageUrl,
    this.averageRating = 0,
    this.totalReviews = 0,
    required this.schedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'cached_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  factory EntityModels.fromMap(String? id, Map<String, dynamic> map) {
    /* final data = doc.data() as Map<String, dynamic>; */
    return EntityModels(
        id: id ?? map['id'],
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

  EntityModels copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? services,
    String? address,
    GeoPoint? localitation,
    String? phone,
    String? imageUrl,
    double? averageRating,
    int? totalReviews,
    String? schedule,
  }) {
    return EntityModels(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      services: services ?? this.services,
      address: address ?? this.address,
      localitation: localitation ?? this.localitation,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      schedule: schedule ?? this.schedule,
    );
  }
}
