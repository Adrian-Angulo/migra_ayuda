import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

/// Clase Singleton para manejar la base de datos Sembast
/// Proporciona una única instancia de la base de datos para toda la aplicación
class SembastDatabase {
  // Singleton instance
  static final SembastDatabase _instance = SembastDatabase._internal();

  // Database instance
  Database? _database;

  // Completer para manejar la inicialización asíncrona
  Completer<Database>? _dbOpenCompleter;

  // Nombre de la base de datos
  static const String _dbName = 'migra_ayuda.db';

  // Constructor privado para Singleton
  SembastDatabase._internal();

  // Getter para obtener la instancia única
  static SembastDatabase get instance => _instance;

  /// Obtiene la instancia de la base de datos
  /// Si no está inicializada, la inicializa automáticamente
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // Si ya hay una inicialización en progreso, espera a que termine
    if (_dbOpenCompleter != null) {
      return _dbOpenCompleter!.future;
    }

    // Inicia la inicialización
    _dbOpenCompleter = Completer();
    await _initDatabase();
    return _dbOpenCompleter!.future;
  }

  /// Inicializa la base de datos Sembast
  Future<void> _initDatabase() async {
    try {
      // Obtiene el directorio de documentos de la aplicación
      final appDocumentDir = await getApplicationDocumentsDirectory();

      // Crea la ruta completa para la base de datos
      final dbPath = join(appDocumentDir.path, _dbName);

      // Abre la base de datos
      _database = await databaseFactoryIo.openDatabase(dbPath);

      // Completa el Future
      _dbOpenCompleter?.complete(_database);
    } catch (e) {
      // En caso de error, completa con error
      _dbOpenCompleter?.completeError(e);
      _dbOpenCompleter = null;
      rethrow;
    }
  }

  /// Cierra la base de datos
  /// Útil para testing o cuando se necesita cerrar explícitamente
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _dbOpenCompleter = null;
    }
  }

  /// Limpia toda la base de datos (útil para testing o reset)
  Future<void> clearAll() async {
    final db = await database;
    await db.close();

    // Obtiene la ruta y elimina el archivo
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, _dbName);
    await databaseFactoryIo.deleteDatabase(dbPath);

    // Reinicia las variables
    _database = null;
    _dbOpenCompleter = null;
  }
}
