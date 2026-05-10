import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/router_notifier.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
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
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              children: [
                Text("Dasboard"),
                ElevatedButton(
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).logout();
                      context.go(Routes.login);
                    },
                    child: const Text("cerrar sesion"))
              ],
            ),
          ),
        ),
      )
      /* ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/dashboard', redirect: (_, __) => '/dashboard/home'),
          GoRoute(
            path: '/dashboard/home',
            builder: (context, state) => const DashboardHomeScreen(),
          ),
          GoRoute(
            path: '/dashboard/userActivity',
            builder: (context, state) => const UserActivityScreen(),
          ),
          GoRoute(
            path: '/dashboard/users',
            builder: (context, state) => const UsersScreen(),
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
            builder: (context, state) => const EntitiesScreen(),
          ),
          GoRoute(
            path: '/dashboard/entities/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EntityDetailScreen(entityId: id);
            },
          ),
        ],
      ), */
    ],
  );
});
