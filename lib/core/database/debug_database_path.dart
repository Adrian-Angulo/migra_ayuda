import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Función de utilidad para imprimir la ruta de la base de datos
Future<String> getDatabasePath() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  final dbPath = join(appDocumentDir.path, 'migra_ayuda.db');

  print('📁 Ruta de la base de datos local:');
  print('   $dbPath');

  return dbPath;
}

/// Función para copiar la ruta al portapapeles (útil en desarrollo)
Future<void> printDatabaseInfo() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  final dbPath = join(appDocumentDir.path, 'migra_ayuda.db');

  print('═══════════════════════════════════════════════════════════');
  print('📊 INFORMACIÓN DE LA BASE DE DATOS LOCAL (SEMBAST)');
  print('═══════════════════════════════════════════════════════════');
  print('📁 Nombre: migra_ayuda.db');
  print('📍 Ruta completa:');
  print('   $dbPath');
  print('📂 Directorio:');
  print('   ${appDocumentDir.path}');
  print('═══════════════════════════════════════════════════════════');
}
