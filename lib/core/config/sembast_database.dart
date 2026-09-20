import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

/// Convertidor para codificar y cifrar datos JSON antes de escribirlos en disco
class _EncryptEncoder extends Converter<Object?, String> {
  final String _key;
  _EncryptEncoder(this._key);

  @override
  String convert(Object? input) {
    final jsonStr = json.encode(input);
    final bytes = utf8.encode(jsonStr);
    final keyBytes = utf8.encode(_key);
    final encrypted = List<int>.generate(
      bytes.length,
      (i) => bytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64.encode(encrypted);
  }
}

/// Convertidor para descifrar y decodificar datos desde el disco
class _EncryptDecoder extends Converter<String, Object?> {
  final String _key;
  _EncryptDecoder(this._key);

  @override
  Object? convert(String input) {
    final encrypted = base64.decode(input);
    final keyBytes = utf8.encode(_key);
    final decrypted = List<int>.generate(
      encrypted.length,
      (i) => encrypted[i] ^ keyBytes[i % keyBytes.length],
    );
    final jsonStr = utf8.decode(decrypted);
    return json.decode(jsonStr);
  }
}

/// Codec de cifrado compatible con Sembast
class _EncryptCodec extends Codec<Object?, String> {
  final String _key;
  _EncryptCodec(this._key);

  @override
  Converter<String, Object?> get decoder => _EncryptDecoder(_key);

  @override
  Converter<Object?, String> get encoder => _EncryptEncoder(_key);
}

/// Singleton para manejar la base de datos local Sembast con soporte de cifrado
class SembastDatabase {
  static final SembastDatabase _instance = SembastDatabase._internal();

  Database? _database;
  Completer<Database>? _dbOpenCompleter;

  static const String _dbName = 'migra_ayuda.db';
  static const String _encryptionKey = 'migra_ayuda_local_storage_key_2026';

  SembastDatabase._internal();

  static SembastDatabase get instance => _instance;

  static SembastCodec get _codec => SembastCodec(
        signature: 'migra_ayuda_encrypted_codec',
        codec: _EncryptCodec(_encryptionKey),
      );

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    if (_dbOpenCompleter != null) {
      return _dbOpenCompleter!.future;
    }

    _dbOpenCompleter = Completer();
    await _initDatabase();
    return _dbOpenCompleter!.future;
  }

  Future<void> _initDatabase() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocumentDir.path, _dbName);

      // Abre la base de datos aplicando el codec de cifrado
      _database = await databaseFactoryIo.openDatabase(
        dbPath,
        codec: _codec,
      );

      _dbOpenCompleter?.complete(_database);
    } catch (e) {
      _dbOpenCompleter?.completeError(e);
      _dbOpenCompleter = null;
      rethrow;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _dbOpenCompleter = null;
    }
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.close();

    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, _dbName);
    await databaseFactoryIo.deleteDatabase(dbPath);

    _database = null;
    _dbOpenCompleter = null;
  }
}
