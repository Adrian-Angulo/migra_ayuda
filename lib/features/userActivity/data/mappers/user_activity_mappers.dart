import 'package:migra_ayuda/features/userActivity/data/models/user_activity_model.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity.dart';

class UserActivityMappers {
  /// Convierte un UserActivityModel a UserActivityEntity
  static UserActivity toActivityEntity(UserActivityModel model) {
    return UserActivity(
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
  static UserActivityModel toActivityModel(UserActivity entity) {
    return UserActivityModel(
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
