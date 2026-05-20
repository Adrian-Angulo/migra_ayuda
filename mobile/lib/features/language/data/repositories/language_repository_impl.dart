import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/language/domain/repositories/language_repository.dart';
import 'package:migra_ayuda/features/language/data/datasources/language_local_datasource.dart';

/// Implementación concreta del repositorio de idioma.
/// Utiliza un DataSource para separar la lógica de persistencia.
class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageLocalDataSource _dataSource;

  LanguageRepositoryImpl(this._dataSource);

  /// Carga el idioma guardado previamente.
  /// Retorna un [Locale] con el código de idioma almacenado, o null si no hay ninguno.
  @override
  Future<Locale?> loadLanguage() async {
    try {
      final languageCode = await _dataSource.getLanguageCode();
      return languageCode != null ? Locale(languageCode) : null;
    } catch (e) {
      // Fallback silencioso: si hay error, retornamos null
      return null;
    }
  }

  /// Guarda el código de idioma seleccionado.
  /// [languageCode] es el código BCP 47 del idioma (por ejemplo, 'es', 'en').
  @override
  Future<void> saveLanguage(String languageCode) async {
    try {
      await _dataSource.saveLanguageCode(languageCode);
    } catch (e) {
      // Relanzamos la excepción para que el provider la maneje
      rethrow;
    }
  }
}
