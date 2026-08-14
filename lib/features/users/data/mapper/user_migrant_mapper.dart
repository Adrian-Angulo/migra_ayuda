import 'package:migra_ayuda/features/users/data/models/migrant_model.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';

class UserMigrantMapper {
  static Migrant fromModel(MigrantModel model) {
    return Migrant(
      id: model.id,
      name: model.name,
      email: model.email,
      originCountry: model.originCountry,
      destinationCountry: model.destinationCountry,
      age: model.age,
      password: '',
      role: model.role,
      profileComplete: model.profileComplete,
      createdAt: model.createdAt,
    );
  }

  static MigrantModel toModel(Migrant entity) {
    return MigrantModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      originCountry: entity.originCountry,
      destinationCountry: entity.destinationCountry,
      age: entity.age,
      role: entity.role,
      profileComplete: entity.profileComplete,
      createdAt: entity.createdAt,
    );
  }
}
