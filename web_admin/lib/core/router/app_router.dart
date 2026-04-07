import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda_administracion/core/router/router_notifier.dart';
import 'package:migra_ayuda_administracion/core/router/routes.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/screens/home_screen.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/screens/login_screen.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/screens/dashboard_home_screen.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/screens/users_screen.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/screens/entities_screen.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/screens/entity_detail_screen.dart';

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
          GoRoute(path: '/dashboard', redirect: (_, __) => '/dashboard/home'),
          GoRoute(
            path: '/dashboard/home',
            builder: (context, state) => const DashboardHomeScreen(),
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
      ),
    ],
  );
});
