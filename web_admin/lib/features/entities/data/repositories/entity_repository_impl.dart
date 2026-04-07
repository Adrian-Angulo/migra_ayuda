// data/repositories/entidad_repository_impl.dart

import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:migra_ayuda_administracion/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda_administracion/features/entities/data/models/entity_models.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/repositories/entity_repository.dart';

class EntityRepositoryImpl implements EntityRepository {
  final EntityRemoteDatasource _datasource;

  EntityRepositoryImpl(this._datasource);

  @override
  Future<Either<String, Unit>> registerEntity({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  }) async {
    try {
      // convierte la entidad del dominio a modelo
      final modelo = EntityModels(
        id: '',
        name: entity.name,
        description: entity.description,
        services: entity.services,
        address: entity.address,
        latitude: entity.latitude,
        longitude: entity.longitude,
        phone: entity.phone,
        serviceHours: entity.serviceHours,
        imageUrl: '',
      );

      await _datasource.registerEntity(
        entityModel: modelo,
        imageBytes: imagenBytes,
        fileName: fileName,
      );

      return right(unit);
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
        latitude: entity.latitude,
        longitude: entity.longitude,
        phone: entity.phone,
        serviceHours: entity.serviceHours,
        imageUrl: entity.imageUrl,
      );

      await _datasource.updateEntity(
        entityModel: modelo,
        imageBytes: imagenBytes,
        fileName: fileName,
      );

      return right(unit);
    } catch (e) {
      return left('Error al actualizar la entidad: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> deleteEntity(String entityId) async {
    try {
      await _datasource.deleteEntity(entityId);
      return right(unit);
    } catch (e) {
      return left('Error al eliminar la entidad: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<EntityEntity>>> getAllEntities() async {
    try {
      final models = await _datasource.getAllEntities();
      return right(models);
    } catch (e) {
      return left('Error al obtener las entidades: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, EntityEntity>> getEntityById(String id) async {
    try {
      final model = await _datasource.getEntityById(id);
      return right(model);
    } catch (e) {
      return left('Error al obtener la entidad: ${e.toString()}');
    }
  }
}
