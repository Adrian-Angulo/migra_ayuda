class UserActivityEntity {
  final String id;
  final String idUser;
  final String accion;
  final DateTime createdAt;

  UserActivityEntity({
    required this.id,
    required this.idUser,
    required this.accion,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
