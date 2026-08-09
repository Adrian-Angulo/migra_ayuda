import 'package:sembast/sembast.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';



/// Implementación del datasource local usando Sembast
class EntityLocalDataSource {
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
        return EntityModels.fromMap(record.key, record.value);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener entidades del caché: $e');
    }
  }

  Future<void> cacheEntities(List<EntityModels> entities) async {
    try {
      final db = await _db;

      // Limpia el store antes de guardar nuevos datos
      await _store.delete(db);

      // Guarda todas las entidades
      for (final entity in entities) {
        await _store.record(entity.id).put(db, entity.toMap());
      }
    } catch (e) {
      throw Exception('Error al guardar entidades en caché: $e');
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

      return EntityModels.fromMap(id, record);
    } catch (e) {
      throw Exception('Error al obtener entidad del caché: $e');
    }
  }

  Future<void> cacheEntity(EntityModels entity) async {
    try {
      final db = await _db;

      // Guarda o actualiza la entidad
      await _store.record(entity.id).put(db, entity.toMap());
    } catch (e) {
      throw Exception('Error al guardar entidad en caché: $e');
    }
  }

  Future<void> deleteEntity(String id) async {
    try {
      final db = await _db;

      // Elimina la entidad por ID
      await _store.record(id).delete(db);
    } catch (e) {
      throw Exception('Error al eliminar entidad del caché: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final db = await _db;

      // Limpia todo el store
      await _store.delete(db);
    } catch (e) {
      throw Exception('Error al limpiar caché: $e');
    }
  }

}
