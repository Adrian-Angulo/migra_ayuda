import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda_administracion/core/router/routes.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/providers/auth_notifier.dart';

class RouterNotifier extends AsyncNotifier<void> implements Listenable {
  VoidCallback? routerListener;

  @override
  FutureOr<void> build() {
    // Escuchar cambios en authNotifierProvider
    ref.listen(authNotifierProvider, (previous, next) {
      // Notificar al router que debe re-evaluar
      routerListener?.call();
    });
  }

  @override
  void addListener(VoidCallback listener) {
    routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    routerListener = null;
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = ref.read(authNotifierProvider);

    if (authState.isLoading) {
      return null;
    }

    final user = authState.value;
    final isGoingToLogin = state.matchedLocation == '/login';

    if (user == null) {
      if (isGoingToLogin) {
        return null;
      }

      return Routes.login;
    }

    if (user.role != 'Admin') {
      return Routes.login;
    }

    if (isGoingToLogin) {
      return Routes.dashboard;
    }

    return null;
  }
}

final routerNotifierProvider = AsyncNotifierProvider<RouterNotifier, void>(
  RouterNotifier.new,
);
