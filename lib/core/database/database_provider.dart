import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'sembast_database.dart';

/// Provider que proporciona la instancia de la base de datos Sembast
/// Este provider se inicializa de forma lazy cuando se necesita
final databaseProvider = FutureProvider<Database>((ref) async {
  final sembastDb = SembastDatabase.instance;
  return await sembastDb.database;
});

/// Provider que proporciona la instancia de SembastDatabase
/// Útil cuando necesitas acceso directo a la clase SembastDatabase
final sembastDatabaseProvider = Provider<SembastDatabase>((ref) {
  return SembastDatabase.instance;
});
