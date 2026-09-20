import 'package:sembast/sembast.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';



class EntityLocalDataSource {
  final SembastDatabase sembastDatabase;


  final _store = stringMapStoreFactory.store('entities');

  EntityLocalDataSource({required this.sembastDatabase});

  
  Future<Database> get _db async => await sembastDatabase.database;

  Future<List<EntityModels>> getCachedEntities() async {
    try {
      final db = await _db;

     
      final finder = Finder(sortOrders: [SortOrder('name')]);
      final records = await _store.find(db, finder: finder);

     
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

      
      await _store.delete(db);

     
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

 
      await _store.record(entity.id).put(db, entity.toMap());
    } catch (e) {
      throw Exception('Error al guardar entidad en caché: $e');
    }
  }

  Future<void> deleteEntity(String id) async {
    try {
      final db = await _db;

  
      await _store.record(id).delete(db);
    } catch (e) {
      throw Exception('Error al eliminar entidad del caché: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final db = await _db;

     
      await _store.delete(db);
    } catch (e) {
      throw Exception('Error al limpiar caché: $e');
    }
  }

}
