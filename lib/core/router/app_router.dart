import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/router_notifier.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/core/widgets/web/activity_chart_card.dart';
import 'package:migra_ayuda/core/widgets/web/dasboard_header.dart';
import 'package:migra_ayuda/core/widgets/web/recent_activities.dart';
import 'package:migra_ayuda/core/widgets/web/section_statics_card.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/login_web.dart';

import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/entities_screen.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/web/reviews_screen.dart';
import 'package:migra_ayuda/features/audit/presentation/screens/web/user_activity_web_screen.dart';
import 'package:migra_ayuda/features/users/presentation/screens/users_screen.dart';

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
            builder: (context, state) => Dashboard(),
          ),
          GoRoute(
              path: '/dashboard/userActivity',
              builder: (context, state) => const UserActivityWebScreen()),
          GoRoute(
              path: '/dashboard/users',
              builder: (context, state) => const UsersScreen()),
          GoRoute(
              path: '/dashboard/reviews',
              builder: (context, state) => const ReviewsScreen()),
          GoRoute(
              path: '/dashboard/entities',
              builder: (context, state) => const EntitiesScreen()),
        ],
      ),
    ],
  );
});

class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //header-----------------
                DashboardHeader(),

                //secciones de cards------
                SectionStaticsCard(),

                //seccion de activis
                Row(
                  spacing: 16,
                  children: [
                    Expanded(flex: 2, child: ActivityChartCard()),
                    Expanded(flex: 1, child: RecentActivities())
                  ],
                ),

                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                        child: SizedBox(
                            height: 350,
                            child: Card(
                              child: Center(
                                child: Text('Grafico'),
                              ),
                            ))),
                    Expanded(
                        child: SizedBox(
                            height: 350,
                            child: Card(
                              child: Center(
                                child: Text('servicios mas filtrados'),
                              ),
                            )))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
