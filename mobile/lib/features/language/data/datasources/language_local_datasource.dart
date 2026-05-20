/// Interface abstracta para el almacenamiento local de preferencias de idioma.
/// Permite separar la lógica de persistencia del repositorio.
abstract class LanguageLocalDataSource {
  /// Obtiene el código de idioma guardado previamente.
  /// Retorna el código de idioma (ej: 'es', 'en') o null si no hay ninguno.
  Future<String?> getLanguageCode();

  /// Guarda el código de idioma seleccionado.
  /// [code] debe ser un código de idioma válido (ej: 'es', 'en').
  Future<void> saveLanguageCode(String code);
}
