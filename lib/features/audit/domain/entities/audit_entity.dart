enum UserAccion { login, logout, seeDetailsEntity, goToEntity }

class AuditEntity {
  final String id;
  final String idUser;
  final String nombre;
  final String correo;
  final String pais;
  final String accion;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  AuditEntity({
    required this.id,
    required this.idUser,
    required this.accion,
    DateTime? createdAt,
    required this.nombre,
    required this.correo,
    required this.pais,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String toString() {
    return 'UserActivity('
        'id: $id, '
        'idUser: $idUser, '
        'nombre: $nombre, '
        'correo: $correo, '
        'pais: $pais, '
        'accion: $accion, '
        'metadata: $metadata, '
        'createdAt: $createdAt'
        ')';
  }
}
