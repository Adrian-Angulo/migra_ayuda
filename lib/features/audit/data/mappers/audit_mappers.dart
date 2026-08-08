import 'package:migra_ayuda/features/audit/data/models/audit_model.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';

class AuditMappers {
  /// Convierte un UserActivityModel a UserActivityEntity
  static AuditEntity toActivityEntity(AuditModel model) {
    return AuditEntity(
      id: model.id,
      idUser: model.idUser,
      accion: model.accion,
      nombre: model.nombre,
      correo: model.correo,
      pais: model.pais,
      createdAt: model.createdAt,
      metadata: model.metadata,
    );
  }

  /// Convierte un UserActivityEntity a UserActivityModel
  static AuditModel toActivityModel(AuditEntity entity) {
    return AuditModel(
      id: entity.id,
      idUser: entity.idUser,
      accion: entity.accion,
      nombre: entity.nombre,
      correo: entity.correo,
      pais: entity.pais,
      createdAt: entity.createdAt,
      isSynced: false,
      metadata: entity.metadata,
    );
  }
}
