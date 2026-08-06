import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:sembast/timestamp.dart';

class ReviewModel {
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
  ReviewModel(
      {required this.id,
      required this.idMigrante,
      required this.idEntity,
      required this.userName,
      required this.userCountry,
      required this.rating,
      required this.comment,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.isSynced,
      required this.nameEntity});

  factory ReviewModel.fromFirebase(
    Map<String, dynamic> map,
  ) {
    return ReviewModel(
      id: map['id'] ?? '',
      idMigrante: map['idMigrante'] ?? '',
      idEntity: map['idEntity'] ?? '',
      rating: (map['rating'] != null) ? (map['rating'] as num).toDouble() : 0.0,
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      deletedAt:
          map['deletedAt'] != null ? DateTime.tryParse(map['deletedAt']) : null,
      isSynced: map['isSynced'] ?? false,
      userName: map['userName'] ?? '',
      userCountry: map['userCountry'] ?? '',
      nameEntity: map['nameEntity'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idMigrante': idMigrante,
      'idEntity': idEntity,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'deletedAt': deletedAt?.toUtc().toIso8601String(),
      'isSynced': isSynced,
      'userName': userName,
      'nameEntity': nameEntity,
      'userCountry': userCountry,
    };
  }

  factory ReviewModel.fromReviewEntity(
    ReviewEntity review, {
    String? id,
    bool isSynced = false,
  }) {
    return ReviewModel(
      id: id ?? review.id,
      idMigrante: review.idMigrante,
      idEntity: review.idEntity,
      userName: review.userName,
      userCountry: review.userCountry,
      rating: review.rating,
      comment: review.comment,
      createdAt: review.createdAt,
      updatedAt: review.updatedAt,
      deletedAt: review.deletedAt,
      isSynced: isSynced,
      nameEntity: review.nameEntity,
    );
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      idMigrante: idMigrante,
      idEntity: idEntity,
      nameEntity: nameEntity,
      userName: userName,
      userCountry: userCountry,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      isSynced: isSynced,
    );
  }

  factory ReviewModel.fromSembastMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      idMigrante: map['idMigrante'] ?? '',
      idEntity: map['idEntity'] ?? '',
      userName: map['userName'] ?? '',
      userCountry: map['userCountry'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
              : DateTime.parse(map['updatedAt']))
          : null,
      deletedAt: map['deletedAt'] != null
          ? (map['deletedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['deletedAt'])
              : DateTime.parse(map['deletedAt']))
          : null,
      isSynced: map['isSynced'] ?? false,
      nameEntity: map['nameEntity'],
    );
  }

  ReviewModel copyWith({
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
    return ReviewModel(
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
