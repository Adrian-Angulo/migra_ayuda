import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';

/// Guarda de redirección para la versión Web (Panel de Administración).
String? webRedirectGuard(BuildContext context, GoRouterState state, Ref ref) {
  final authState = ref.read(authNotifierProvider);

  // 1. Si el estado de autenticación aún está cargando, no redirigir
  if (authState.isLoading) {
    return null;
  }

  final user = authState.value;
  final currentPath = state.matchedLocation;
  final isPublicRoute =
      currentPath == Routes.login || currentPath == Routes.resetPassword;

  // 2. Usuario no autenticado
  if (user == null) {
    if (isPublicRoute) {
      return null;
    }
    return Routes.login;
  }

  // 3. Usuario autenticado pero sin rol de Administrador
  if (user.role != 'Admin') {
    if (currentPath == Routes.login) {
      return null;
    }
    return Routes.login;
  }

  // 4. Usuario Administrador autenticado intentando entrar a login o reset-password
  if (isPublicRoute) {
    return Routes.dashboardHome;
  }

  return null;
}
