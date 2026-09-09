import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/onboarding/presentation/providers/onboarding_provider.dart';

/// Guarda de redirección para la versión Mobile.
String? mobileRedirectGuard(
    BuildContext context, GoRouterState state, Ref ref) {
  final currentPath = state.matchedLocation;

  // 1. Si estamos en splashInit, no redirigir
  if (currentPath == Routes.splashInit) {
    return null;
  }

  final onboardingState = ref.read(onboardingProvider);
  final authState = ref.read(authNotifierProvider);

  // 2. Si el estado aún está cargando inicialmente, permitir continuar sin saltos
  if (onboardingState.isLoading || authState.isLoading) {
    return null;
  }

  // 3. Verificación de Onboarding
  final hasSeenOnboarding =
      onboardingState.value == true && !onboardingState.hasError;

  if (!hasSeenOnboarding) {
    if (currentPath == Routes.onboarding) return null;
    return Routes.onboarding;
  }

  // Si ya vio onboarding pero intenta ingresar a onboarding de nuevo
  if (currentPath == Routes.onboarding) {
    return Routes.loginMovil;
  }

  // 4. Verificación de Autenticación (Rutas públicas)
  final user = authState.value;
  final isAuthRoute = currentPath == Routes.loginMovil ||
      currentPath == Routes.registerMovil ||
      currentPath == Routes.resetPassword;

  if (user == null) {
    if (isAuthRoute) return null;
    return Routes.loginMovil;
  }

  // 5. Verificación de Perfil Completo
  if (!user.profileComplete) {
    if (currentPath == Routes.completeProfile) return null;
    return Routes.completeProfile;
  }

  // 6. Si el perfil está completo y el usuario está en rutas de autenticación o completar perfil
  final isAuthOrCompleteRoute =
      isAuthRoute || currentPath == Routes.completeProfile;

  if (user.role == 'Migrante' && isAuthOrCompleteRoute) {
    return Routes.home;
  }

  return null;
}
