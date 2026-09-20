import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

abstract class EntityRepository {
  Future<Either<Failure, void>> registerEntity({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  });

  Future<Either<Failure, void>> updateEntity({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  });

  Future<Either<Failure, void>> deleteEntity(String entityId);
  Stream<List<EntityEntity>> getAllEntites2();
  Future<Either<Failure, List<EntityEntity>>> getAllEntities();
  Future<Either<Failure, EntityEntity>> getEntityById(String id);
  Future<Either<Failure, void>> syncAllFromFirebase();
}
