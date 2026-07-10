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
      required super.isSynced,
      required super.nameEntity});

  factory ReviewModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ReviewModel(
      id: map['id'],
      idMigrante: map['idMigrante'],
      idEntity: map['idEntity'],
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
      isSynced: map['isSynced'],
      userName: map['userName'],
      userCountry: map['userCountry'],
      nameEntity: map['nameEntity'],
    );
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
      'nameEntity': nameEntity,
      'userCountry': userCountry,
    };
  }

  /// Convierte ReviewModel a Map para Sembast
  Map<String, dynamic> toSembastMap() {
    return {
      'idMigrante': idMigrante,
      'idEntity': idEntity,
      'userName': userName,
      'userCountry': userCountry,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
      'isSynced': isSynced,
      'nameEntity': nameEntity,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Convierte Map de Sembast a ReviewModel
  factory ReviewModel.fromSembastMap(String id, Map<String, dynamic> map) {
    // Determina si createdAt es int (milliseconds) o String (ISO8601)
    DateTime createdAt;
    if (map['createdAt'] is int) {
      // Ya está en formato correcto (milliseconds)
      createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt']);
    } else if (map['createdAt'] is String) {
      // Está en formato String ISO8601 - convertir
      createdAt = DateTime.parse(map['createdAt']);
    } else {
      // Fallback a fecha actual
      createdAt = DateTime.now();
    }

    return ReviewModel(
      id: id,
      idMigrante: map['idMigrante'] ?? '',
      idEntity: map['idEntity'] ?? '',
      userName: map['userName'] ?? '',
      userCountry: map['userCountry'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: createdAt,
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

  @override
  ReviewModel copyWith({
    String? id,
    String? idMigrante,
    String? idEntity,
    String? userName,
    String? userCountry,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
    String? nameEntity,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      idMigrante: idMigrante ?? this.idMigrante,
      idEntity: idEntity ?? this.idEntity,
      userName: userName ?? this.userName,
      userCountry: userCountry ?? this.userCountry,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      nameEntity: nameEntity ?? this.nameEntity,
    );
  }
}
