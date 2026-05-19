// data/repositories/entidad_repository_impl.dart

import 'dart:typed_data';

import 'package:dartz/dartz.dart';
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
  Future<Either<String, Unit>> registerEntity({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  }) async {
    try {
      final modelo = EntityModels(
        id: '',
        name: entity.name,
        description: entity.description,
        services: entity.services,
        address: entity.address,
        localitation: entity.localitation,
        phone: entity.phone,
        serviceHours: entity.serviceHours,
        imageUrl: '',
      );

      // Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // Si hay internet, registra en Firebase
        await remoteDataSource.registerEntity(
          entityModel: modelo,
          imageBytes: imagenBytes,
          fileName: fileName,
        );

        // Actualiza el caché después de registrar
        final entities = await remoteDataSource.getAllEntities();
        await localDataSource.cacheEntities(entities);
      } else {
        // Sin internet, retorna error (no se puede subir imagen sin conexión)
        return left(
            'No hay conexión a internet. Se requiere conexión para registrar entidades con imágenes.');
      }

      return right(unit);
    } on ServerException catch (e) {
      return left('Error del servidor: ${e.message}');
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al registrar la entidad: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> updateEntity({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  }) async {
    try {
      final modelo = EntityModels(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        services: entity.services,
        address: entity.address,
        localitation: entity.localitation,
        phone: entity.phone,
        serviceHours: entity.serviceHours,
        imageUrl: entity.imageUrl,
      );

      // Primero actualiza en caché local
      await localDataSource.cacheEntity(modelo);

      // Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // Si hay internet, sincroniza con Firebase
        try {
          await remoteDataSource.updateEntity(
            entityModel: modelo,
            imageBytes: imagenBytes,
            fileName: fileName,
          );
        } catch (e) {
          // Si falla Firebase, los datos ya están en caché
          return left(
              'Actualizado localmente. Error al sincronizar: ${e.toString()}');
        }
      }
      // Si no hay internet, solo se actualiza localmente

      return right(unit);
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al actualizar la entidad: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> deleteEntity(String entityId) async {
    try {
      // Primero elimina del caché local
      await localDataSource.deleteEntity(entityId);

      // Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // Si hay internet, elimina de Firebase
        try {
          await remoteDataSource.deleteEntity(entityId);
        } catch (e) {
          // Si falla Firebase, ya está eliminado localmente
          return left(
              'Eliminado localmente. Error al sincronizar: ${e.toString()}');
        }
      }
      // Si no hay internet, solo se elimina localmente

      return right(unit);
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al eliminar la entidad: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<EntityEntity>>> getAllEntities() async {
    try {
      // ESTRATEGIA CACHE-FIRST:
      // 1. Primero intenta obtener del caché (respuesta inmediata)
      List<EntityModels> cachedEntities = [];

      try {
        cachedEntities = await localDataSource.getCachedEntities();
      } catch (e) {
        // Si falla el caché, continúa con lista vacía
        cachedEntities = [];
      }

      // 2. Verifica si hay conexión para actualizar en background
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // Obtiene datos frescos de Firebase
          final remoteEntities = await remoteDataSource.getAllEntities();

          // Actualiza el caché con los datos frescos
          await localDataSource.cacheEntities(remoteEntities);

          // Retorna los datos frescos de Firebase
          return right(remoteEntities);
        } on ServerException catch (e) {
          // Si falla Firebase pero hay caché, retorna el caché
          if (cachedEntities.isNotEmpty) {
            return right(cachedEntities);
          }
          return left('Error del servidor: ${e.message}');
        }
      }

      // 3. Sin internet, retorna el caché
      if (cachedEntities.isNotEmpty) {
        return right(cachedEntities);
      }

      // 4. Sin caché y sin internet
      return left('No hay datos disponibles. Verifica tu conexión a internet.');
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al obtener las entidades: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, EntityEntity>> getEntityById(String id) async {
    try {
      // ESTRATEGIA CACHE-FIRST:
      // 1. Primero intenta obtener del caché
      EntityModels? cachedEntity;

      try {
        cachedEntity = await localDataSource.getEntityById(id);
      } catch (e) {
        // Si falla el caché, continúa
        cachedEntity = null;
      }

      // 2. Verifica si hay conexión
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // Obtiene datos frescos de Firebase
          final remoteEntity = await remoteDataSource.getEntityById(id);

          // Actualiza el caché
          await localDataSource.cacheEntity(remoteEntity);

          // Retorna los datos frescos
          return right(remoteEntity);
        } on ServerException catch (e) {
          // Si falla Firebase pero hay caché, retorna el caché
          if (cachedEntity != null) {
            return right(cachedEntity);
          }
          return left('Error del servidor: ${e.message}');
        }
      }

      // 3. Sin internet, retorna el caché
      if (cachedEntity != null) {
        return right(cachedEntity);
      }

      // 4. Sin caché y sin internet
      return left(
          'Entidad no disponible offline. Verifica tu conexión a internet.');
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left('Error al obtener la entidad: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> syncAllFromFirebase() async {
    try {
      // 1. Verificar conexión a internet
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return left('Sin conexión a internet para sincronizar');
      }

      // 2. Descargar TODAS las entidades de Firebase
      final remoteEntities = await remoteDataSource.getAllEntities();

      // 3. Limpiar caché y guardar todo
      await localDataSource.clearCache();
      await localDataSource.cacheEntities(remoteEntities);

      return right(unit);
    } on ServerException catch (e) {
      return left('Error del servidor: ${e.message}');
    } on CacheException catch (e) {
      return left('Error de caché: ${e.message}');
    } catch (e) {
      return left(
          'Error al sincronizar entidades desde Firebase: ${e.toString()}');
    }
  }
}
