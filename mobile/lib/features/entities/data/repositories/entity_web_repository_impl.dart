import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/entities/data/datasources/entity_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_repository.dart';

/// Implementación del repositorio de entidades para WEB

class EntityWebRepositoryImpl extends EntityRepository {
  final EntityRemoteDataSource remoteDataSource;

  EntityWebRepositoryImpl({required this.remoteDataSource});

  /// Registra una nueva entidad en Firebase
  ///
  /// Este método:
  /// 1. Convierte la entidad del dominio a modelo de datos
  /// 2. Sube la imagen a Cloudinary
  /// 3. Guarda la entidad en Firebase con la URL de la imagen
  ///
  /// Requiere conexión a internet (no hay fallback offline en web)
  @override
  Future<Either<String, Unit>> registerEntity({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  }) async {
    try {
      // Convertir entidad del dominio a modelo de datos
      final modelo = EntityModels(
        id: '', // Firebase generará el ID
        name: entity.name,
        description: entity.description,
        services: entity.services,
        address: entity.address,
        localitation: entity.localitation,
        phone: entity.phone,
        serviceHours: entity.serviceHours,
        imageUrl: '', // Se actualizará después de subir la imagen
      );

      // Registrar en Firebase (incluye subida de imagen a Cloudinary)
      await remoteDataSource.registerEntity(
        entityModel: modelo,
        imageBytes: imagenBytes,
        fileName: fileName,
      );

      return right(unit);
    } on ServerException catch (e) {
      return left('Error del servidor: ${e.message}');
    } catch (e) {
      return left('Error al registrar la entidad: ${e.toString()}');
    }
  }

  /// Actualiza una entidad existente en Firebase
  ///
  /// Este método:
  /// 1. Convierte la entidad del dominio a modelo de datos
  /// 2. Si se proporciona una nueva imagen, la sube a Cloudinary
  /// 3. Actualiza la entidad en Firebase
  ///
  /// Parámetros opcionales:
  /// - imagenBytes: Nueva imagen (si se quiere cambiar)
  /// - fileName: Nombre del archivo de la nueva imagen
  @override
  Future<Either<String, Unit>> updateEntity({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  }) async {
    try {
      // Convertir entidad del dominio a modelo de datos
      final modelo = EntityModels(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        services: entity.services,
        address: entity.address,
        localitation: entity.localitation,
        phone: entity.phone,
        serviceHours: entity.serviceHours,
        imageUrl:
            entity.imageUrl, // Mantiene la URL actual si no hay nueva imagen
      );

      // Actualizar en Firebase (sube nueva imagen si se proporciona)
      await remoteDataSource.updateEntity(
        entityModel: modelo,
        imageBytes: imagenBytes,
        fileName: fileName,
      );

      return right(unit);
    } on ServerException catch (e) {
      return left('Error del servidor: ${e.message}');
    } catch (e) {
      return left('Error al actualizar la entidad: ${e.toString()}');
    }
  }

  /// Elimina una entidad de Firebase
  ///
  /// Este método elimina permanentemente la entidad de Firebase.
  @override
  Future<Either<String, Unit>> deleteEntity(String entityId) async {
    try {
      // Eliminar directamente de Firebase
      await remoteDataSource.deleteEntity(entityId);

      return right(unit);
    } on ServerException catch (e) {
      return left('Error del servidor: ${e.message}');
    } catch (e) {
      return left('Error al eliminar la entidad: ${e.toString()}');
    }
  }

  /// Obtiene todas las entidades desde Firebase
  ///
  /// Este método retorna siempre datos frescos directamente desde Firebase.
  /// No usa caché local, por lo que requiere conexión a internet.
  @override
  Future<Either<String, List<EntityEntity>>> getAllEntities() async {
    try {
      // Obtener entidades directamente desde Firebase
      final entities = await remoteDataSource.getAllEntities();

      return right(entities);
    } on ServerException catch (e) {
      return left('Error del servidor: ${e.message}');
    } catch (e) {
      return left('Error al obtener las entidades: ${e.toString()}');
    }
  }

  /// Obtiene una entidad específica por ID desde Firebase
  ///
  /// Este método retorna siempre datos frescos directamente desde Firebase.
  /// No usa caché local, por lo que requiere conexión a internet.
  @override
  Future<Either<String, EntityEntity>> getEntityById(String id) async {
    try {
      // Obtener entidad directamente desde Firebase
      final entity = await remoteDataSource.getEntityById(id);

      return right(entity);
    } on ServerException catch (e) {
      return left('Error del servidor: ${e.message}');
    } catch (e) {
      return left('Error al obtener la entidad: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Unit>> syncAllFromFirebase() {
    throw UnimplementedError(
      'syncAllFromFirebase no está disponible en la versión web. '
      'En web, cada llamada a getAllEntities() ya obtiene datos frescos de Firebase.',
    );
  }
}
