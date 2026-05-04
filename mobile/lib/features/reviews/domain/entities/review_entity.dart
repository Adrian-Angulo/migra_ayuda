class ReviewEntity {
  final String id;
  final String idMigrante;
  final String idEntity;
  final String userName;
  final String userCountry;

  final double rating;
  final String comment;

  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  final bool isSynced;

  const ReviewEntity({
    required this.id,
    required this.idMigrante,
    required this.idEntity,
    required this.userName,
    required this.userCountry,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.isSynced,
  });
}