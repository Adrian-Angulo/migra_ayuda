/// Utilidad para normalizar direcciones colombianas y optimizar la precisión
/// en los servicios de geocodificación (como Mapbox Places).
class AddressNormalizer {
  /// Normaliza una dirección antes de enviarla a la API de geocodificación.
  ///
  /// Transforma abreviaturas como "Cra.", "Cl.", "Av." a sus nombres completos,
  /// remueve símbolos como '#' o 'No.' que confunden los motores de búsqueda globales,
  /// y añade contexto de la ciudad si no está presente.
  static String normalize(String rawAddress, {String defaultCity = 'Pasto'}) {
    var cleaned = rawAddress.trim();
    if (cleaned.isEmpty) return cleaned;

    // 1. Expandir abreviaturas comunes (con o sin punto al final)
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(cl|cll|c)\.?(?=\s|$)', caseSensitive: false),
      'Calle',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(cra|cr|kra|kr|k)\.?(?=\s|$)', caseSensitive: false),
      'Carrera',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(av|avda)\.?(?=\s|$)', caseSensitive: false),
      'Avenida',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(dg|diag)\.?(?=\s|$)', caseSensitive: false),
      'Diagonal',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(tv|trans)\.?(?=\s|$)', caseSensitive: false),
      'Transversal',
    );

    // 2. Reemplazar símbolos como #, No., N° por espacios limpios
    cleaned = cleaned.replaceAll(
      RegExp(r'[#№]|(?:\bNo\.?\s*)', caseSensitive: false),
      ' ',
    );

    // 3. Limpiar espacios múltiples y comas redundantes
    cleaned = cleaned
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*,\s*'), ', ')
        .trim();

    // 4. Asegurar que contenga la ciudad de referencia para acotar la búsqueda
    final cityLower = defaultCity.toLowerCase();
    if (!cleaned.toLowerCase().contains(cityLower)) {
      cleaned = '$cleaned, $defaultCity';
    }

    return cleaned;
  }
}
