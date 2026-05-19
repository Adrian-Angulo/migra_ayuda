import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/router_notifier.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/login_web.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/entities_screen.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/entity_detail_screen.dart';
import 'package:migra_ayuda/features/userActivity/presentation/screens/user_activity_screen.dart';

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
            builder: (context, state) => Column(
              children: [
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, 3),
                            FlSpot(1, 5),
                            FlSpot(2, 4),
                            FlSpot(3, 7),
                            FlSpot(4, 6),
                          ],
                          isCurved: true,
                          barWidth: 4,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          GoRoute(
              path: '/dashboard/userActivity',
              builder: (context, state) => const UserActivityScreen()),
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
              builder: (context, state) => const EntitiesScreen()),
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
