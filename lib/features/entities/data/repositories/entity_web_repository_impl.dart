import 'dart:typed_data';
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
  Future<void> registerEntity({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  }) async {
    // Convertir entidad del dominio a modelo de datos
    final modelo = EntityModels(
        id: '', // Firebase generará el ID
        name: entity.name,
        description: entity.description,
        services: entity.services,
        address: entity.address,
        localitation: entity.localitation,
        phone: entity.phone,
        imageUrl: '', // Se actualizará después de subir la imagen
        schedule: entity.schedule);

    // Registrar en Firebase (incluye subida de imagen a Cloudinary)
    await remoteDataSource.registerEntity(
      entityModel: modelo,
      imageBytes: imagenBytes,
      fileName: fileName,
    );
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
  Future<void> updateEntity({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  }) async {
    // Convertir entidad del dominio a modelo de datos
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
        imageUrl:
            entity.imageUrl, // Mantiene la URL actual si no hay nueva imagen
        schedule: entity.schedule);

    // Actualizar en Firebase (sube nueva imagen si se proporciona)
    await remoteDataSource.updateEntity(
      entityModel: modelo,
      imageBytes: imagenBytes,
      fileName: fileName,
    );
  }

  /// Elimina una entidad de Firebase
  ///
  /// Este método elimina permanentemente la entidad de Firebase.
  @override
  Future<void> deleteEntity(String entityId) async {
    // Eliminar directamente de Firebase
    await remoteDataSource.deleteEntity(entityId);
  }

  /// Obtiene todas las entidades desde Firebase
  ///
  /// Este método retorna siempre datos frescos directamente desde Firebase.
  /// No usa caché local, por lo que requiere conexión a internet.
  @override
  Future<List<EntityEntity>> getAllEntities() async {
    // Obtener entidades directamente desde Firebase
    final entitiesModel = await remoteDataSource.getAllEntities();
    // Mapear de EntityModels a EntityEntity
    return entitiesModel
        .map((e) => _entityModelsToEntityEntity(e))
        .toList();
  }

  /// Obtiene una entidad específica por ID desde Firebase
  ///
  /// Este método retorna siempre datos frescos directamente desde Firebase.
  /// No usa caché local, por lo que requiere conexión a internet.
  @override
  Future<EntityEntity> getEntityById(String id) async {
    // Obtener entidad directamente desde Firebase
    final entityModel = await remoteDataSource.getEntityById(id);
    return _entityModelsToEntityEntity(entityModel);
  }

  @override
  Future<void> syncAllFromFirebase() {
    throw UnimplementedError(
      'syncAllFromFirebase no está disponible en la versión web. '
      'En web, cada llamada a getAllEntities() ya obtiene datos frescos de Firebase.',
    );
  }

  @override
  Stream<List<EntityEntity>> getAllEntites2() {
    return remoteDataSource.getAllEntitiesStream().map((list) {
      return list.map((e) => _entityModelsToEntityEntity(e)).toList();
    });
  }

  // Helper para convertir EntityModels a EntityEntity (para mantener consistencia)
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
