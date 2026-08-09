import 'package:cloud_firestore/cloud_firestore.dart';

class EntityEntity {
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

  const EntityEntity({
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

  EntityEntity copyWith({
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
    String? schedule
  }) {
    return EntityEntity(
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
      schedule: schedule ?? this.schedule
    );
  }
}
