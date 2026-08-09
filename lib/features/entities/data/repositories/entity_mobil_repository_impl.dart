import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:migra_ayuda/core/network/network_info.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_local_datasource.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
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
      await remoteDataSource.registerEntity(
        entityModel: modelo,
        imageBytes: imagenBytes,
        fileName: fileName,
      );

      final entities = await remoteDataSource.getAllEntities();
      await localDataSource.cacheEntities(entities);
    } else {
      throw Exception(
          'No hay conexión a internet. Se requiere conexión para registrar entidades con imágenes.');
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
      } catch (e) {
        // Si falla Firebase, los datos ya están en caché, pero avisamos mediante excepción
        throw Exception(
            'Actualizado localmente. Error al sincronizar: ${e.toString()}');
      }
    }
    // Si no hay internet, solo se actualiza localmente
  }

  @override
  Future<void> deleteEntity(String entityId) async {
    await localDataSource.deleteEntity(entityId);

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        await remoteDataSource.deleteEntity(entityId);
      } catch (e) {
        // Si falla Firebase, ya está eliminado localmente, pero avisamos mediante excepción
        throw Exception(
            'Eliminado localmente. Error al sincronizar: ${e.toString()}');
      }
    }
    // Si no hay internet, solo se elimina localmente
  }

  @override
  Future<List<EntityEntity>> getAllEntities() async {
    // Estrategia cache-first
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
        // Convertir a EntityEntity para el dominio
        return remoteEntities
            .map((e) => _entityModelsToEntityEntity(e))
            .toList();
      } catch (e) {
        // Si falla Firebase pero hay caché, retorna el caché
        if (cachedEntities.isNotEmpty) {
          return cachedEntities
              .map((e) => _entityModelsToEntityEntity(e))
              .toList();
        }
        throw Exception('Error del servidor: ${e.toString()}');
      }
    }

    if (cachedEntities.isNotEmpty) {
      return cachedEntities
          .map((e) => _entityModelsToEntityEntity(e))
          .toList();
    }

    throw Exception(
        'No hay datos disponibles. Verifica tu conexión a internet.');
  }

  @override
  Future<EntityEntity> getEntityById(String id) async {
    EntityModels? cachedEntity;

    try {
      cachedEntity = await localDataSource.getEntityById(id);
    } catch (e) {
      cachedEntity = null;
    }

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteEntity = await remoteDataSource.getEntityById(id);
        await localDataSource.cacheEntity(remoteEntity);
        return _entityModelsToEntityEntity(remoteEntity);
      } catch (e) {
        if (cachedEntity != null) {
          return _entityModelsToEntityEntity(cachedEntity);
        }
        throw Exception('Error del servidor: ${e.toString()}');
      }
    }

    if (cachedEntity != null) {
      return _entityModelsToEntityEntity(cachedEntity);
    }

    throw Exception(
        'Entidad no disponible offline. Verifica tu conexión a internet.');
  }

  @override
  Future<void> syncAllFromFirebase() async {
    debugPrint('iniciando sincronizacion');
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      debugPrint('sin conexion');
      throw Exception('Sin conexión a internet para sincronizar');
    }
    debugPrint('existe conexion');
    final remoteEntities = await remoteDataSource.getAllEntities();
    debugPrint('entidades descargadas');
    await localDataSource.clearCache();
    debugPrint('limpiando cache');
    await localDataSource.cacheEntities(remoteEntities);
    debugPrint('agregando entidades a cache');
  }

  @override
  Stream<List<EntityEntity>> getAllEntites2() {
    throw UnimplementedError();
  }

  // Helper for conversion (puedes mover esto a otro sitio si lo prefieres)
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
