
class EmailValidator {
  // ─── 1. VALIDAR FORMATO ───────────────────────────────────────────────────

  /// Retorna null si es válido, o un mensaje de error si no lo es.
  /// Úsalo directo en el validator de un TextFormField.
  static String? validateFormat(String? email) {
    if (email == null || email.isEmpty) {
      return 'El correo no puede estar vacío';
    }

    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

    if (!regex.hasMatch(email.trim())) {
      return 'Ingresa un correo válido';
    }

    return null; // null = válido
  }

}
