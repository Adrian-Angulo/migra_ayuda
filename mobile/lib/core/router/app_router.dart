import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/router_notifier.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/login_web.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider.notifier);

  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginWeb(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/dashboard', redirect: (_, __) => '/dashboard/home'),
          GoRoute(
            path: '/dashboard/home',
            builder: (context, state) => const Center(
              child: Text("Dasboard"),
            ),
          ),
          GoRoute(
            path: '/dashboard/userActivity',
            builder: (context, state) => const Center(
              child: Text("Actividades"),
            ),
          ),
          GoRoute(
            path: '/dashboard/users',
            builder: (context, state) => const Center(
              child: Text("Usuarios"),
            ),
          ),
          GoRoute(
            path: '/dashboard/services',
            builder: (context, state) => const Center(
              child: Text(
                "Servicios",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GoRoute(
            path: '/dashboard/entities',
            builder: (context, state) => const Center(
              child: Text("Entidades"),
            ),
          ),
          /* GoRoute(
            path: '/dashboard/entities/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EntityDetailScreen(entityId: id);
            },
          ), */
        ],
      ),
    ],
  );
});
