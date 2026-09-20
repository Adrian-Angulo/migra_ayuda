import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/core/network/network_info.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_local_datasource.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/failures/entity_failures.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_repository.dart';

class EntityMobilRepositoryImpl implements EntityRepository {
  final EntityRemoteDataSource remoteDataSource;
  final EntityLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EntityMobilRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

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

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        await remoteDataSource.registerEntity(
          entityModel: modelo,
          imageBytes: imagenBytes,
          fileName: fileName,
        );

        final entities = await remoteDataSource.getAllEntities();
        await localDataSource.cacheEntities(entities);
        return const Right(null);
      } catch (_) {
        return const Left(EntityCreationFailedFailure());
      }
    } else {
      return const Left(NetworkFailure());
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

    await localDataSource.cacheEntity(modelo);

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
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
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteEntity(String entityId) async {
    await localDataSource.deleteEntity(entityId);

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        await remoteDataSource.deleteEntity(entityId);
        return const Right(null);
      } catch (_) {
        return const Left(EntityDeletionFailedFailure());
      }
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<EntityEntity>>> getAllEntities() async {
    List<EntityModels> cachedEntities = [];
    try {
      cachedEntities = await localDataSource.getCachedEntities();
    } catch (_) {
      cachedEntities = [];
    }

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteEntities = await remoteDataSource.getAllEntities();
        await localDataSource.cacheEntities(remoteEntities);
        final entities =
            remoteEntities.map((e) => _entityModelsToEntityEntity(e)).toList();
        return Right(entities);
      } catch (_) {
        if (cachedEntities.isNotEmpty) {
          final entities =
              cachedEntities.map((e) => _entityModelsToEntityEntity(e)).toList();
          return Right(entities);
        }
        return const Left(EntityFetchFailedFailure());
      }
    }

    if (cachedEntities.isNotEmpty) {
      final entities =
          cachedEntities.map((e) => _entityModelsToEntityEntity(e)).toList();
      return Right(entities);
    }

    return const Left(NetworkFailure());
  }

  @override
  Future<Either<Failure, EntityEntity>> getEntityById(String id) async {
    EntityModels? cachedEntity;

    try {
      cachedEntity = await localDataSource.getEntityById(id);
    } catch (_) {
      cachedEntity = null;
    }

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteEntity = await remoteDataSource.getEntityById(id);
        await localDataSource.cacheEntity(remoteEntity);
        return Right(_entityModelsToEntityEntity(remoteEntity));
      } catch (_) {
        if (cachedEntity != null) {
          return Right(_entityModelsToEntityEntity(cachedEntity));
        }
        return const Left(EntityFetchFailedFailure());
      }
    }

    if (cachedEntity != null) {
      return Right(_entityModelsToEntityEntity(cachedEntity));
    }

    return const Left(EntityNotFoundFailure());
  }

  @override
  Future<Either<Failure, void>> syncAllFromFirebase() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final remoteEntities = await remoteDataSource.getAllEntities();
      await localDataSource.clearCache();
      await localDataSource.cacheEntities(remoteEntities);
      return const Right(null);
    } catch (_) {
      return const Left(EntityFetchFailedFailure());
    }
  }

  @override
  Stream<List<EntityEntity>> getAllEntites2() {
    throw UnimplementedError();
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
