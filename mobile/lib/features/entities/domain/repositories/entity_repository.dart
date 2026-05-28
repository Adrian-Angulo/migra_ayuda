import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

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

  Future<Either<String, Unit>> deleteEntity(String entityId);

  Stream<Either<String, List<EntityEntity>>> getAllEntites2();

  Future<Either<String, List<EntityEntity>>> getAllEntities();

  Future<Either<String, EntityEntity>> getEntityById(String id);

  /// Sincroniza todas las entidades desde Firebase a la base de datos local
  ///
  /// Este método descarga TODAS las entidades de Firebase y las guarda en Sembast.
  /// Retorna [Right(Unit)] si la sincronización fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, Unit>> syncAllFromFirebase();
  
}
