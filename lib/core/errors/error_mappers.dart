import 'package:flutter/cupertino.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class ErrorMappers {
  /// Obtener mensaje de error amigable
  static String getAuthErrorMessage(String error, BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    switch (error) {
      case 'user-not-found':
        return l10n.authErrorUserNotFoundCode;
      case 'wrong-password':
        return l10n.authErrorWrongPassword;
      case 'invalid-email':
        return l10n.authErrorInvalidEmailCode;
      case 'user-disabled':
        return l10n.authErrorUserDisabled;
      case 'email-already-in-use':
        return l10n.authErrorEmailAlreadyInUse;
      case 'operation-not-allowed':
        return l10n.authErrorOperationNotAllowedCode;
      case 'weak-password':
        return l10n.authErrorWeakPasswordCode;
      case 'account-exists-with-different-credential':
        return l10n.authErrorAccountExistsWithDifferentCredential;
      case 'invalid-credential':
        return l10n.authErrorInvalidCredentialCode;
      case 'network-request-failed':
        return l10n.authErrorNetworkRequestFailed;
      default:
        return l10n.authErrorDefault;
    }
  }
}
