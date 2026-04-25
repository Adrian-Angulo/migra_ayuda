import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_repository.dart';


class GetEntityByIdUsecase {
  final EntityRepository repository;

  GetEntityByIdUsecase({required this.repository});

  Future<Either<String, EntityEntity>> call(String id) async {
    return await repository.getEntityById(id);
  }
}
