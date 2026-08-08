import 'package:sembast/sembast.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/features/audit/data/models/audit_model.dart';

class AuditLocalDataSource {
  final SembastDatabase sembastDatabase = SembastDatabase.instance;

  // Store para las actividades de usuario
  final _store = stringMapStoreFactory.store('user_activities');

  /// Obtiene la instancia de la base de datos
  Future<Database> get _db async => await sembastDatabase.database;

  Future<void> save(AuditModel activity) async {
    try {
      final db = await _db;

      // Guarda o actualiza la actividad
      await _store.record(activity.id).put(db, activity.toMap());
    } catch (e) {
      throw Exception('Error al guardar actividad en caché: $e');
    }
  }

  Future<void> delete(String localId) async {
    try {
      final db = await _db;
      await _store.record(localId).delete(db);
    } catch (e) {
      throw Exception('Error al eliminar actividad local: $e');
    }
  }

  Future<List<AuditModel>> getPending() async {
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
        return AuditModel.fromMap(record.key, record.value);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener actividades pendientes: $e');
    }
  }
}
