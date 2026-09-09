import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/onboarding/presentation/providers/onboarding_provider.dart';

/// Notificador reactivo centralizado para GoRouter.
/// Escucha los cambios de estado relevantes y notifica automáticamente al router.
class AppRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  AppRouterNotifier(this._ref) {
    // Escucha cambios en el estado de autenticación
    _ref.listen(authNotifierProvider, (previous, next) {
      notifyListeners();
    });

    // Escucha cambios en el estado de onboarding
    _ref.listen(onboardingProvider, (previous, next) {
      notifyListeners();
    });
  }
}

/// Provider para el notificador reactivo del router.
final appRouterNotifierProvider = Provider<AppRouterNotifier>((ref) {
  return AppRouterNotifier(ref);
});
