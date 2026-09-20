import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/failures/entity_failures.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_repository.dart';

class EntityWebRepositoryImpl extends EntityRepository {
  final EntityRemoteDataSource remoteDataSource;

  EntityWebRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> registerEntity({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  }) async {
    final modelo = EntityModels(
      id: '',
      name: entity.name,
      description: entity.description,
      services: entity.services,
      address: entity.address,
      localitation: entity.localitation,
      phone: entity.phone,
      imageUrl: '',
      schedule: entity.schedule,
    );

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
    final modelo = EntityModels(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      services: entity.services,
      address: entity.address,
      localitation: entity.localitation,
      phone: entity.phone,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
      imageUrl: entity.imageUrl,
      schedule: entity.schedule,
    );

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
      await remoteDataSource.deleteEntity(entityId);
      return const Right(null);
    } catch (_) {
      return const Left(EntityDeletionFailedFailure());
    }
  }

  @override
  Future<Either<Failure, List<EntityEntity>>> getAllEntities() async {
    try {
      final entitiesModel = await remoteDataSource.getAllEntities();
      final entities =
          entitiesModel.map((e) => _entityModelsToEntityEntity(e)).toList();
      return Right(entities);
    } catch (_) {
      return const Left(EntityFetchFailedFailure());
    }
  }

  @override
  Future<Either<Failure, EntityEntity>> getEntityById(String id) async {
    try {
      final entityModel = await remoteDataSource.getEntityById(id);
      return Right(_entityModelsToEntityEntity(entityModel));
    } catch (_) {
      return const Left(EntityNotFoundFailure());
    }
  }

  @override
  Future<Either<Failure, void>> syncAllFromFirebase() async {
    return const Left(
      UnexpectedFailure(
       
      ),
    );
  }

  @override
  Stream<List<EntityEntity>> getAllEntites2() {
    return remoteDataSource.getAllEntitiesStream().map((list) {
      return list.map((e) => _entityModelsToEntityEntity(e)).toList();
    }).handleError((_) {
      throw const EntityFetchFailedFailure();
    });
  }

  EntityEntity _entityModelsToEntityEntity(EntityModels modelo) {
    return EntityEntity(
      id: modelo.id,
      name: modelo.name,
      description: modelo.description,
      services: modelo.services,
      address: modelo.address,
      localitation: modelo.localitation,
      phone: modelo.phone,
      imageUrl: modelo.imageUrl,
      averageRating: modelo.averageRating,
      totalReviews: modelo.totalReviews,
      schedule: modelo.schedule,
    );
  }
}
