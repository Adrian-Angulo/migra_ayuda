import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sembast/sembast.dart';
import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';

/// Excepción personalizada para errores de caché
class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}


/// Implementación del datasource local usando Sembast
class EntityLocalDataSource{
  final SembastDatabase sembastDatabase;

  // Store para las entidades
  final _store = stringMapStoreFactory.store('entities');

  EntityLocalDataSource({required this.sembastDatabase});

  /// Obtiene la instancia de la base de datos
  Future<Database> get _db async => await sembastDatabase.database;


  Future<List<EntityModels>> getCachedEntities() async {
    try {
      final db = await _db;

      // Obtiene todos los registros ordenados por nombre
      final finder = Finder(sortOrders: [SortOrder('name')]);
      final records = await _store.find(db, finder: finder);

      // Convierte los registros a EntityModels
      return records.map((record) {
        return _fromSembastMap(record.key, record.value);
      }).toList();
    } catch (e) {
      throw CacheException('Error al obtener entidades del caché: $e');
    }
  }

  Future<void> cacheEntities(List<EntityModels> entities) async {
    try {
      final db = await _db;

      // Limpia el store antes de guardar nuevos datos
      await _store.delete(db);

      // Guarda todas las entidades
      for (final entity in entities) {
        await _store.record(entity.id).put(db, _toSembastMap(entity));
      }
    } catch (e) {
      throw CacheException('Error al guardar entidades en caché: $e');
    }
  }


  Future<EntityModels?> getEntityById(String id) async {
    try {
      final db = await _db;

      // Busca el registro por ID
      final record = await _store.record(id).get(db);

      if (record == null) {
        return null;
      }

      return _fromSembastMap(id, record);
    } catch (e) {
      throw CacheException('Error al obtener entidad del caché: $e');
    }
  }

  Future<void> cacheEntity(EntityModels entity) async {
    try {
      final db = await _db;

      // Guarda o actualiza la entidad
      await _store.record(entity.id).put(db, _toSembastMap(entity));
    } catch (e) {
      throw CacheException('Error al guardar entidad en caché: $e');
    }
  }


  Future<void> deleteEntity(String id) async {
    try {
      final db = await _db;

      // Elimina la entidad por ID
      await _store.record(id).delete(db);
    } catch (e) {
      throw CacheException('Error al eliminar entidad del caché: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final db = await _db;

      // Limpia todo el store
      await _store.delete(db);
    } catch (e) {
      throw CacheException('Error al limpiar caché: $e');
    }
  }

  /// Convierte EntityModels a Map para Sembast
  Map<String, dynamic> _toSembastMap(EntityModels entity) {
    return {
      'name': entity.name,
      'description': entity.description,
      'services': entity.services,
      'address': entity.address,
      'localitation_latitude': entity.localitation.latitude,
      'localitation_longitude': entity.localitation.longitude,
      'phone': entity.phone,
      'service_hours': entity.serviceHours,
      'image_url': entity.imageUrl,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Convierte Map de Sembast a EntityModels
  EntityModels _fromSembastMap(String id, Map<String, dynamic> map) {
    return EntityModels(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      services: (map['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      address: map['address'] ?? '',
      localitation: GeoPoint(
        map['localitation_latitude'] ?? 0.0,
        map['localitation_longitude'] ?? 0.0,
      ),
      phone: map['phone'] ?? '',
      serviceHours: map['service_hours'] ?? '',
      imageUrl: map['image_url'] ?? '',
    );
  }
}
