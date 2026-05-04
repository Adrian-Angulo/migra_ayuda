import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel(
      {required super.id,
      required super.idMigrante,
      required super.idEntity,
      required super.userName,
      required super.userCountry,
      required super.rating,
      required super.comment,
      required super.createdAt,
      required super.updatedAt,
      required super.deletedAt,
      required super.isSynced});

  factory ReviewModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ReviewModel(
      id: map['id'] as String,
      idMigrante: map['idMigrante'] as String,
      idEntity: map['idEntity'] as String,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
      isSynced: map['isSynced'] as bool,
      userName: map['userName'] as String,
      userCountry: map['userCountry'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idMigrante': idMigrante,
      'idEntity': idEntity,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isSynced': isSynced,
      'userName': userName,
      'userCountry': userCountry,
    };
  }
}
