

import 'package:migra_ayuda_administracion/features/userActivity/domain/entities/user_activity_entity.dart';

/// Modelo de datos para UserActivity
///
/// Extiende la entidad del dominio y agrega funcionalidad de serialización
/// y el campo `isSynced` para control de sincronización offline-first.
class UserActivityModel extends UserActivityEntity {
  /// Indica si la actividad está sincronizada con Firebase
  final bool isSynced;

  UserActivityModel({
    required super.id,
    required super.idUser,
    required super.accion,
    required super.createdAt,
    required this.isSynced,
  });

  /// Crea un UserActivityModel desde un Map
  ///
  /// Usado para deserializar datos de Firebase o Sembast
  factory UserActivityModel.fromMap(Map<String, dynamic> map) {
    return UserActivityModel(
      id: map['id'] as String,
      idUser: map['idUser'] as String,
      accion: map['accion'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }

  /// Convierte el modelo a Map
  ///
  /// Usado para serializar datos hacia Firebase o Sembast
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idUser': idUser,
      'accion': accion,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

    /// Convierte UserActivityModel a Map para Sembast
  Map<String, dynamic> toSembastMap() {
    return {
      'idUser': idUser,
      'accion': accion,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isSynced': isSynced,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

    /// Convierte Map de Sembast a UserActivityModel
  factory UserActivityModel.fromSembastMap(String id, Map<String, dynamic> map) {
    return UserActivityModel(
      id: id,
      idUser: map['idUser'] ?? '',
      accion: map['accion'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isSynced: map['isSynced'] ?? false,
    );
  }

  /// Crea una copia del modelo con campos actualizados
  UserActivityModel copyWith({
    String? id,
    String? idUser,
    String? accion,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return UserActivityModel(
      id: id ?? this.id,
      idUser: idUser ?? this.idUser,
      accion: accion ?? this.accion,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
