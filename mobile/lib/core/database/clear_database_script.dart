import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:sembast/sembast.dart';

/// Script temporal para limpiar la base de datos corrupta
///
/// USO:
/// 1. Importa este archivo en tu main.dart o en un botón de debug
/// 2. Ejecuta clearDatabaseAndRestart()
/// 3. Elimina este archivo después de usarlo
Future<void> clearDatabaseAndRestart() async {
  try {
    print('🗑️ Limpiando base de datos local...');

    // Limpia toda la base de datos
    await SembastDatabase.instance.clearAll();

    print('✅ Base de datos limpiada exitosamente');
    print('🔄 Reinicia la app para que funcione correctamente');
  } catch (e) {
    print('❌ Error al limpiar base de datos: $e');
  }
}

/// Alternativa: Solo limpiar el store de reviews
Future<void> clearReviewsOnly() async {
  try {
    final db = await SembastDatabase.instance.database;
    final reviewsStore = stringMapStoreFactory.store('reviews');

    print('🗑️ Limpiando solo reviews...');
    await reviewsStore.delete(db);
    print('✅ Reviews eliminadas exitosamente');
  } catch (e) {
    print('❌ Error al limpiar reviews: $e');
  }
}
