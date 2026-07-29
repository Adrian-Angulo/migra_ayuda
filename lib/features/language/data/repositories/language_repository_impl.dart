import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/language/domain/repositories/language_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementación concreta del repositorio de idioma.
/// Utiliza un DataSource para separar la lógica de persistencia.
class LanguageRepositoryImpl implements LanguageRepository {
  

  LanguageRepositoryImpl();

  /// Carga el idioma guardado previamente.
  /// Retorna un [Locale] con el código de idioma almacenado, o null si no hay ninguno.
  @override
  Future<Locale?> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languaje = prefs.getString('language');
      return languaje != null ? Locale(languaje) : null;
    } catch (e) {
      // En caso de error, retornamos null (idioma no guardado)
      return null;
    }
  }

  /// Guarda el código de idioma seleccionado.
  /// [languageCode] es el código BCP 47 del idioma (por ejemplo, 'es', 'en').
  @override
  Future<void> saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
    
      await prefs.setString('language', languageCode);
      debugPrint('lenguaje guardado: $languageCode');
     
    } catch (e) {
      debugPrint('Error al guardar el leguaje seleccionado: $e');
      throw Exception(e);
    }
  }
}
