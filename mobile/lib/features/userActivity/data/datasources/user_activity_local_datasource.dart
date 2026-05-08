import 'package:sembast/sembast.dart';
import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:migra_ayuda/features/userActivity/data/models/user_activity_model.dart';

/// Excepción personalizada para errores de caché
class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Implementación del datasource local usando Sembast
class UserActivityLocalDataSource {
  final SembastDatabase sembastDatabase = SembastDatabase.instance;

  // Store para las actividades de usuario
  final _store = stringMapStoreFactory.store('user_activities');

  /// Obtiene la instancia de la base de datos
  Future<Database> get _db async => await sembastDatabase.database;

  Future<void> cacheActivity(UserActivityModel activity) async {
    try {
      final db = await _db;

      // Guarda o actualiza la actividad
      await _store.record(activity.id).put(db, activity.toSembastMap());
    } catch (e) {
      throw CacheException('Error al guardar actividad en caché: $e');
    }
  }

  Future<List<UserActivityModel>> getPendingActivities() async {
    try {
      final db = await _db;

      // Filtra por isSynced = false
      final finder = Finder(
        filter: Filter.equals('isSynced', false),
        sortOrders: [SortOrder('createdAt', false)], // Más recientes primero
      );
      final records = await _store.find(db, finder: finder);

      // Convierte los registros a UserActivityModel
      return records.map((record) {
        return UserActivityModel.fromSembastMap(record.key, record.value);
      }).toList();
    } catch (e) {
      throw CacheException('Error al obtener actividades pendientes: $e');
    }
  }

  Future<void> markAsSynced(String activityId) async {
    try {
      final db = await _db;

      // Obtiene la actividad actual
      final record = await _store.record(activityId).get(db);

      if (record == null) {
        throw CacheException('Actividad no encontrada en caché');
      }

      // Marca como sincronizada
      final updatedRecord = Map<String, dynamic>.from(record);
      updatedRecord['isSynced'] = true;

      // Actualiza el registro
      await _store.record(activityId).put(db, updatedRecord);
    } catch (e) {
      throw CacheException('Error al marcar actividad como sincronizada: $e');
    }
  }

  Future<void> deleteLocalRecord(String recordId) async {
    try {
      final db = await _db;

      // Elimina el registro físicamente (hard delete)
      await _store.record(recordId).delete(db);
    } catch (e) {
      throw CacheException('Error al eliminar registro local: $e');
    }
  }

  Future<void> updateActivityId(
      String localId, UserActivityModel syncedModel) async {
    try {
      final db = await _db;

      // Operación atómica: elimina el registro antiguo e inserta el nuevo
      // en una sola transacción para prevenir condiciones de carrera
      await db.transaction((txn) async {
        // 1. Eliminar el registro con ID local
        await _store.record(localId).delete(txn);

        // 2. Insertar el registro con ID de Firebase
        await _store
            .record(syncedModel.id)
            .put(txn, syncedModel.toSembastMap());
      });
    } catch (e) {
      throw CacheException('Error al actualizar ID de actividad: $e');
    }
  }
}
