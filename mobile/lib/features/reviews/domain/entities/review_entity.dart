class ReviewEntity {
  final String id;
  final String idMigrante;
  final String idEntity;
  final String nameEntity;
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
    required this.nameEntity,
  });

  ReviewEntity copyWith({
    String? id,
    String? idMigrante,
    String? idEntity,
    String? nameEntity,
    String? userName,
    String? userCountry,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      idMigrante: idMigrante ?? this.idMigrante,
      idEntity: idEntity ?? this.idEntity,
      nameEntity: nameEntity ?? this.nameEntity,
      userName: userName ?? this.userName,
      userCountry: userCountry ?? this.userCountry,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
