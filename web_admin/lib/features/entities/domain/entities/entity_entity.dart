import 'package:cloud_firestore/cloud_firestore.dart';

class EntityEntity {
  final String id;
  final String name;
  final String description;
  final List<String> services;
  final String address;
  final GeoPoint localitation;
  final String phone;
  final String serviceHours;
  final String imageUrl;

  const EntityEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.services,
    required this.address,
    required this.localitation,
    required this.phone,
    required this.serviceHours,
    required this.imageUrl,
  });
}
