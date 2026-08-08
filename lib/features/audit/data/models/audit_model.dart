class AuditModel {
  final bool isSynced;
  final String id;
  final String idUser;
  final String nombre;
  final String correo;
  final String pais;
  final String accion;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  AuditModel(
      {required this.id,
      required this.idUser,
      required this.accion,
      required this.createdAt,
      required this.isSynced,
      required this.nombre,
      required this.correo,
      required this.pais,
      this.metadata});

  factory AuditModel.fromMap(String? id, Map<String, dynamic> map) {
    return AuditModel(
      id: id ?? map['id'] as String,
      idUser: map['idUser'] as String,
      accion: map['accion'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      isSynced: map['isSynced'] as bool? ?? false,
      nombre: map['nombre'] as String? ?? '',
      correo: map['correo'] as String? ?? '',
      pais: map['pais'] as String? ?? '',
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idUser': idUser,
      'accion': accion,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'isSynced': isSynced,
      'nombre': nombre,
      'correo': correo,
      'pais': pais,
      'metadata': metadata
    };
  }

  /// Crea una copia del modelo con campos actualizados
  AuditModel copyWith(
      {String? id,
      String? idUser,
      String? accion,
      DateTime? createdAt,
      bool? isSynced,
      String? nombre,
      String? correo,
      String? pais,
      Map<String, dynamic>? metadata}) {
    return AuditModel(
        id: id ?? this.id,
        idUser: idUser ?? this.idUser,
        accion: accion ?? this.accion,
        createdAt: createdAt ?? this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        nombre: nombre ?? this.nombre,
        correo: correo ?? this.correo,
        pais: pais ?? this.pais,
        metadata: metadata ?? this.metadata);
  }
}
