import 'package:flutter/material.dart';

/// Clase utilitaria centralizada para traducir y formatear errores técnicos
/// en mensajes amigables, claros y empáticos para los usuarios.
class ErrorMappers {
  /// Retorna un mensaje de error limpio y comprensible a partir de cualquier objeto de error o cadena.
  static String getFriendlyErrorMessage(dynamic error,
      {String? defaultMessage, BuildContext? context}) {
    if (error == null) {
      return defaultMessage ?? 'Ha ocurrido un error inesperado.';
    }

    final String raw = error.toString().trim();
    if (raw.isEmpty) {
      return defaultMessage ?? 'Ha ocurrido un error inesperado.';
    }

    // 1. Detección de problemas de conexión / red
    if (_isNetworkError(raw)) {
      return 'No hay conexión a internet o la señal es inestable. Verifica tu red e inténtalo de nuevo.';
    }

    // 2. Detección de errores de Firebase Authentication
    final authMessage = _checkFirebaseAuthError(raw);
    if (authMessage != null) {
      return authMessage;
    }

    // 3. Detección de errores de Firestore / Base de datos / Servidor
    final firestoreMessage = _checkFirestoreError(raw);
    if (firestoreMessage != null) {
      return firestoreMessage;
    }

    // 4. Detección de errores de subida de imágenes / Cloudinary
    if (raw.toLowerCase().contains('cloudinary') ||
        raw.toLowerCase().contains('subir imagen') ||
        raw.toLowerCase().contains('upload image')) {
      return 'No se pudo procesar o subir la imagen. Verifica el archivo e inténtalo de nuevo.';
    }

    // 5. Detección de errores de entidades y reseñas
    if (raw.contains('Entidad no encontrada')) {
      return 'No fue posible encontrar la información de este lugar o servicio.';
    }
    if (raw.toLowerCase().contains('error al crear la review') ||
        raw.toLowerCase().contains('error al guardar review')) {
      return 'No se pudo publicar tu reseña en este momento. Por favor, intenta de nuevo.';
    }
    if (raw.toLowerCase().contains('error al actualizar la review') ||
        raw.toLowerCase().contains('error al actualizar review')) {
      return 'No se pudo actualizar tu comentario. Intenta nuevamente.';
    }
    if (raw.toLowerCase().contains('error al eliminar la review') ||
        raw.toLowerCase().contains('error al eliminar review')) {
      return 'No se pudo eliminar el comentario. Intenta nuevamente.';
    }

    // 6. Limpieza de prefijos comunes para mensajes limpios
    final cleaned = _cleanTechnicalPrefixes(raw);

    // Si tras la limpieza quedó un mensaje corto y legible (en español), lo mostramos
    if (cleaned.isNotEmpty && !_isRawStackTraceOrCode(cleaned)) {
      return cleaned;
    }

    return defaultMessage ??
        'Ha ocurrido un inconveniente. Por favor, inténtalo nuevamente.';
  }

  /// Método de conveniencia para autenticación (mantiene compatibilidad con llamadas existentes)
  static String getAuthErrorMessage(dynamic error, [BuildContext? context]) {
    return getFriendlyErrorMessage(error,
        defaultMessage: 'Error al procesar la autenticación. Intenta nuevamente.',
        context: context);
  }

  // ---------------------------------------------------------------------------
  // Métodos auxiliares de clasificación
  // ---------------------------------------------------------------------------

  static bool _isNetworkError(String text) {
    final lower = text.toLowerCase();
    return lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network-request-failed') ||
        lower.contains('networkrequestfailed') ||
        lower.contains('timeoutexception') ||
        lower.contains('connection timed out') ||
        lower.contains('connection refused') ||
        lower.contains('clientexception') ||
        lower.contains('sin conexión') ||
        lower.contains('no hay conexión');
  }

  static String? _checkFirebaseAuthError(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('email-not-verified') ||
        lower.contains('email_not_verified')) {
      return 'Debes verificar tu correo electrónico antes de ingresar. Por favor, revisa tu bandeja de entrada.';
    }
    if (lower.contains('user-not-found') ||
        lower.contains('user_not_found')) {
      return 'No existe una cuenta registrada con este correo electrónico.';
    }
    if (lower.contains('wrong-password') ||
        lower.contains('wrong_password')) {
      return 'La contraseña ingresada es incorrecta.';
    }
    if (lower.contains('invalid-credential') ||
        lower.contains('invalid_credential')) {
      return 'Credenciales inválidas. Verifica tu correo y contraseña.';
    }
    if (lower.contains('email-already-in-use') ||
        lower.contains('email_already_in_use') ||
        lower.contains('email already in use')) {
      return 'Este correo electrónico ya se encuentra registrado. Intenta iniciar sesión.';
    }
    if (lower.contains('weak-password') ||
        lower.contains('weak_password')) {
      return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
    }
    if (lower.contains('invalid-email') ||
        lower.contains('invalid_email')) {
      return 'El formato del correo electrónico no es válido.';
    }
    if (lower.contains('user-disabled') ||
        lower.contains('user_disabled')) {
      return 'Esta cuenta de usuario ha sido desactivada. Contacta con soporte.';
    }
    if (lower.contains('too-many-requests') ||
        lower.contains('too_many_requests')) {
      return 'Demasiados intentos fallidos. Por seguridad, espera unos momentos antes de reintentar.';
    }
    if (lower.contains('operation-not-allowed') ||
        lower.contains('operation_not_allowed')) {
      return 'Esta operación no está permitida en este momento.';
    }
    if (lower.contains('account-exists-with-different-credential')) {
      return 'Ya existe una cuenta vinculada con otro método de acceso.';
    }
    if (lower.contains('requires-recent-login')) {
      return 'Por seguridad, vuelve a iniciar sesión para realizar esta acción.';
    }

    return null;
  }

  static String? _checkFirestoreError(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('permission-denied') ||
        lower.contains('permission_denied')) {
      return 'No tienes permisos suficientes para realizar esta acción.';
    }
    if (lower.contains('unavailable') || lower.contains('deadline-exceeded')) {
      return 'El servidor no está disponible en este momento. Intenta de nuevo más tarde.';
    }
    if (lower.contains('serverexception')) {
      return 'Ocurrió un problema en el servidor. Por favor, intenta de nuevo más tarde.';
    }
    return null;
  }

  static String _cleanTechnicalPrefixes(String text) {
    var cleaned = text;

    // Remover prefijos comunes como Exception:, ServerException:, Error:, etc.
    final prefixes = [
      RegExp(r'^Exception:\s*', caseSensitive: false),
      RegExp(r'^ServerException:\s*', caseSensitive: false),
      RegExp(r'^ClientException:\s*', caseSensitive: false),
      RegExp(r'^FormatException:\s*', caseSensitive: false),
      RegExp(r'^Error:\s*', caseSensitive: false),
      RegExp(r'^\[.*?\]\s*'), // Quita [firebase_auth/...]
    ];

    for (final p in prefixes) {
      cleaned = cleaned.replaceAll(p, '');
    }

    return cleaned.trim();
  }

  static bool _isRawStackTraceOrCode(String text) {
    // Si contiene código Dart, stacktrace o nombres de paquetes técnicos
    return text.contains('#0 ') ||
        text.contains('.dart:') ||
        text.contains('package:') ||
        text.contains('NoSuchMethodError') ||
        text.contains('Null check operator');
  }
}
