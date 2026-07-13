import 'package:flutter/rendering.dart';
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
    debugPrint('🗑️ Limpiando base de datos local...');

    // Limpia toda la base de datos
    await SembastDatabase.instance.clearAll();

    debugPrint('✅ Base de datos limpiada exitosamente');
    
  } catch (e) {
    debugPrint('❌ Error al limpiar base de datos: $e');
  }
}

/// Alternativa: Solo limpiar el store de reviews
Future<void> clearReviewsOnly() async {
  try {
    final db = await SembastDatabase.instance.database;
    final reviewsStore = stringMapStoreFactory.store('reviews');

    debugPrint('🗑️ Limpiando solo reviews...');
    await reviewsStore.delete(db);
    debugPrint('✅ Reviews eliminadas exitosamente');
  } catch (e) {
    print('❌ Error al limpiar reviews: $e');
  }
}
