/// Validador de direcciones para el registro o edición de entidades.
class AddressValidator {
  static const int _minAddressLength = 5;

  /// Valida que la dirección no esté vacía y que tenga una longitud mínima representativa.
  /// Permite nomenclaturas estándar colombianas (Calle, Cra, Av, etc.) o nombres de lugares de interés (POIs).
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dirección o punto de referencia es requerido';
    }

    final trimmed = value.trim();

    if (trimmed.length < _minAddressLength) {
      return 'La dirección debe tener al menos $_minAddressLength caracteres';
    }

    return null;
  }
}
