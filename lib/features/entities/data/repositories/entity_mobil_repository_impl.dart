import 'dart:typed_data';
import 'package:flutter/rendering.dart';
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
  Future<void> registerEntity({
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
        schedule: entity.schedule);

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
      } catch (_) {
        throw const EntityCreationFailedFailure();
      }
    } else {
      throw const NetworkFailure();
    }
  }

  @override
  Future<void> updateEntity({
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
        schedule: entity.schedule);

    await localDataSource.cacheEntity(modelo);

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        await remoteDataSource.updateEntity(
          entityModel: modelo,
          imageBytes: imagenBytes,
          fileName: fileName,
        );
      } catch (_) {
        throw const EntityUpdateFailedFailure();
      }
    }
  }

  @override
  Future<void> deleteEntity(String entityId) async {
    await localDataSource.deleteEntity(entityId);

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        await remoteDataSource.deleteEntity(entityId);
      } catch (_) {
        throw const EntityDeletionFailedFailure();
      }
    }
  }

  @override
  Future<List<EntityEntity>> getAllEntities() async {
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
        return remoteEntities
            .map((e) => _entityModelsToEntityEntity(e))
            .toList();
      } catch (_) {
        if (cachedEntities.isNotEmpty) {
          return cachedEntities
              .map((e) => _entityModelsToEntityEntity(e))
              .toList();
        }
        throw const EntityFetchFailedFailure();
      }
    }

    if (cachedEntities.isNotEmpty) {
      return cachedEntities
          .map((e) => _entityModelsToEntityEntity(e))
          .toList();
    }

    throw const NetworkFailure();
  }

  @override
  Future<EntityEntity> getEntityById(String id) async {
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
        return _entityModelsToEntityEntity(remoteEntity);
      } catch (_) {
        if (cachedEntity != null) {
          return _entityModelsToEntityEntity(cachedEntity);
        }
        throw const EntityFetchFailedFailure();
      }
    }

    if (cachedEntity != null) {
      return _entityModelsToEntityEntity(cachedEntity);
    }

    throw const EntityNotFoundFailure();
  }

  @override
  Future<void> syncAllFromFirebase() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      throw const NetworkFailure();
    }
    try {
      final remoteEntities = await remoteDataSource.getAllEntities();
      await localDataSource.clearCache();
      await localDataSource.cacheEntities(remoteEntities);
    } catch (_) {
      throw const EntityFetchFailedFailure();
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
