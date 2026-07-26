import 'package:sembast/sembast.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
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

  Future<void> save(UserActivityModel activity) async {
    try {
      final db = await _db;

      // Guarda o actualiza la actividad
      await _store.record(activity.id).put(db, activity.toSembastMap());
    } catch (e) {
      throw CacheException('Error al guardar actividad en caché: $e');
    }
  }

  Future<void> delete(String localId) async {
    try {
      final db = await _db;
      await _store.record(localId).delete(db);
    } catch (e) {
      throw CacheException('Error al eliminar actividad local: $e');
    }
  }

  Future<List<UserActivityModel>> getPending() async {
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
}
