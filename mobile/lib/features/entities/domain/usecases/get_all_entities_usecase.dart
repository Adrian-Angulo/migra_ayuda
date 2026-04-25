import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_repository.dart';


class GetAllEntitiesUsecase {
  final EntityRepository repository;

  GetAllEntitiesUsecase({required this.repository});

  Future<Either<String, List<EntityEntity>>> call() async {
    return await repository.getAllEntities();
  }
}
