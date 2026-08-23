import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/router_notifier.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/core/widgets/web/not_found_page.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/reset_password/send_email_screen.dart';
import 'package:migra_ayuda/features/dashboard/presentation/dasboard_screen.dart';
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
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginWeb(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const SendEmailScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/dashboard', redirect: (_, __) => '/dashboard/home'),
          GoRoute(
            path: '/dashboard/home',
            builder: (context, state) => const Dashboard(),
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
