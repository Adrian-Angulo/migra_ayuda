import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

abstract class EntityMobileRepository {
  Future<Either<Failure, List<EntityEntity>>> getAllEntities();
  Future<Either<Failure, void>> syncAllFromFirebase();
}
