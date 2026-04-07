import 'package:dartz/dartz.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/repositories/entity_repository.dart';

class DeleteEntityUsecase {
  final EntityRepository repository;

  DeleteEntityUsecase({required this.repository});

  Future<Either<String, Unit>> call(String entityId) async {
    return await repository.deleteEntity(entityId);
  }
}
