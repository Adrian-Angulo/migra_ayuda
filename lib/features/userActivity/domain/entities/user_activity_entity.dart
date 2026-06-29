enum UserAccion { login, logout, seeDetailsEntity, goToEntity }

class UserActivityEntity {
  final String id;
  final String idUser;
  final String nombre;
  final String correo;
  final String pais;
  final String accion;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  UserActivityEntity({
    required this.id,
    required this.idUser,
    required this.accion,
    DateTime? createdAt,
    required this.nombre,
    required this.correo,
    required this.pais,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();
}
