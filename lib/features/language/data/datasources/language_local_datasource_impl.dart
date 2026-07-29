import 'package:shared_preferences/shared_preferences.dart';

/// Implementación concreta del DataSource usando SharedPreferences.
class LanguageLocalDataSourceImpl {
  static const _languageKey = 'language';

  
  Future<String?> getLanguageCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey);
    } catch (e) {
      // En caso de error, retornamos null (idioma no guardado)
      return null;
    }
  }

  
  Future<void> saveLanguageCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, code);
    } catch (e) {
      // Relanzamos la excepción para que el repositorio la maneje
      rethrow;
    }
  }
}
