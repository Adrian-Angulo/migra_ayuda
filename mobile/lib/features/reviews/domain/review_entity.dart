import 'package:sembast/timestamp.dart';

class ReviewEntity {
  final String id;
  final String idMigrante;
  final String idEntity;
  final String userName;
  final String userContry;
  final double rating;
  final String comment;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final Timestamp? deletedAt;
  final bool isSynced;

  ReviewEntity(
      {required this.id,
      required this.idMigrante,
      required this.idEntity,
      required this.rating,
      required this.comment,
      required this.createdAt,
      this.updatedAt,
      this.deletedAt,
      required this.isSynced,
      required this.userName,
      required this.userContry});
}
