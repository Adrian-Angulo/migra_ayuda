import 'package:shared_preferences/shared_preferences.dart';
import 'language_local_datasource.dart';

/// Implementación concreta del DataSource usando SharedPreferences.
class LanguageLocalDataSourceImpl implements LanguageLocalDataSource {
  static const _languageKey = 'language';

  @override
  Future<String?> getLanguageCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey);
    } catch (e) {
      // En caso de error, retornamos null (idioma no guardado)
      return null;
    }
  }

  @override
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
