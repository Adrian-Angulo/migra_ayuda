import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/mappers/entity_mappers.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/failures/entity_failures.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_web_repository.dart';

class EntityWebRepositoryImpl extends EntityWebRepository {
  final EntityRemoteDataSource remoteDataSource;

  EntityWebRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> registerEntity({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  }) async {
    final modelo = EntityMappers.toModel(entity);

    try {
      await remoteDataSource.registerEntity(
        entityModel: modelo,
        imageBytes: imagenBytes,
        fileName: fileName,
      );
      return const Right(null);
    } catch (_) {
      return const Left(EntityCreationFailedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateEntity({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  }) async {
    final modelo = EntityMappers.toModel(entity);

    try {
      await remoteDataSource.updateEntity(
        entityModel: modelo,
        imageBytes: imagenBytes,
        fileName: fileName,
      );
      return const Right(null);
    } catch (_) {
      return const Left(EntityUpdateFailedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntity(String entityId) async {
    try {
      await remoteDataSource.deleteEntity(entityId );
      return const Right(null);
    } catch (_) {
      return const Left(EntityDeletionFailedFailure());
    }
  }



  @override
  Future<Either<Failure, EntityEntity>> getEntityById(String id) async {
    try {
      final entityModel = await remoteDataSource.getEntityById(id);
      return Right(EntityMappers.toEntity(entityModel));
    } catch (_) {
      return const Left(EntityNotFoundFailure());
    }
  }


  @override
  Stream<List<EntityEntity>> getAllEntites2() {
    return remoteDataSource.getAllEntitiesStream().map((list) {
      return list.map((e) => EntityMappers.toEntity(e)).toList();
    }).handleError((_) {
      throw const EntityFetchFailedFailure();
    });
  }
}
