import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda_administracion/core/router/router_notifier.dart';
import 'package:migra_ayuda_administracion/core/router/routes.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/screens/home_screen.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/screens/login_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider.notifier);

  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            redirect: (_, __) => '/dashboard/home', // redirección por defecto
          ),
          GoRoute(
            path: '/dashboard/home', // ← esta faltaba
            builder: (context, state) => const Center(child: Text("home")),
          ),
          GoRoute(
            path: '/dashboard/users',
            builder: (context, state) => const Center(child: Text("Usuarios")),
          ),
          GoRoute(
            path: '/dashboard/services',
            builder: (context, state) => const Center(child: Text("Servicios")),
          ),
          GoRoute(
            path: '/dashboard/entities',
            builder: (context, state) => const Center(child: Text("Entidades")),
          ),
        ],
      ),
    ],
  );
});
