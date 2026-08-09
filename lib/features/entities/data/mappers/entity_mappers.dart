import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

class EntityMappers {
  static EntityEntity toEntity(EntityModels model) {
    return EntityEntity(
        id: model.id,
        name: model.name,
        description: model.description,
        services: model.services,
        address: model.address,
        localitation: model.localitation,
        phone: model.phone,
        imageUrl: model.imageUrl,
        schedule: model.schedule);
  }

  static EntityModels toModel(EntityEntity entity) {
    return EntityModels(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        services: entity.services,
        address: entity.address,
        localitation: entity.localitation,
        phone: entity.phone,
        imageUrl: entity.imageUrl,
        schedule: entity.schedule);
  }
}
