import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/entities/entity_entity.dart';

abstract class EntityRepository {
  Future<Either<String, Unit>> registerEntity({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  });

  Future<Either<String, Unit>> updateEntity({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  });

  Future<Either<String, List<EntityEntity>>> getAllEntities();

  Future<Either<String, EntityEntity>> getEntityById(String id);
}
