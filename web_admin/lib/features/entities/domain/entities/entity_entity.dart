class EntityEntity {
  final String id;
  final String name;
  final String description;
  final List<String> services;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String serviceHours;
  final String imageUrl;

  const EntityEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.services,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.serviceHours,
    required this.imageUrl,
  });
}
