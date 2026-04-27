import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/constants/route_names.dart';
import 'package:migra_ayuda/features/home/presentation/screens/home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/admin/home_screen_admin.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/auth_page.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/complete_info_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/reset_password/send_email_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/reset_password/success_screen.dart';
import 'package:migra_ayuda/features/language/presentation/screens/language_screen.dart';
import 'package:migra_ayuda/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:migra_ayuda/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboarding = ref.watch(onboardingProvider);
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: RouteNames.root,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isOnboarded = hasCompletedOnboarding;
      final user = authState.value;

      final isGoingToOnboarding =
          state.matchedLocation == RouteNames.onboarding;
      final isGoingToLanguage = state.matchedLocation == RouteNames.language;
      final isGoingToAuth = state.matchedLocation == RouteNames.auth;
      final isGoingToCompleteInfo =
          state.matchedLocation == RouteNames.completeInfo;
      final isGoingToHome = state.matchedLocation == RouteNames.home;
      final isGoingToAdmin = state.matchedLocation == RouteNames.admin;
      final isGoingToForgotPassword =
          state.matchedLocation == RouteNames.forgotPassword;
      final isGoingToPasswordSuccess =
          state.matchedLocation == RouteNames.passwordSuccess;

      // Si no ha completado onboarding, redirigir a onboarding
      if (!isOnboarded && !isGoingToOnboarding) {
        return RouteNames.onboarding;
      }
      if (isOnboarded && user == null && !isGoingToLanguage && !isGoingToAuth) {
        return RouteNames.language;
      }

      // Si completó onboarding y va a language, permitir
      if (isOnboarded && isGoingToLanguage) {
        return null; // Permitir ir a language
      }

      // Si completó onboarding pero no está autenticado y NO va a language/forgot/success, ir a auth
      if (isOnboarded &&
          user == null &&
          !isGoingToAuth &&
          !isGoingToLanguage &&
          !isGoingToForgotPassword &&
          !isGoingToPasswordSuccess) {
        return RouteNames.auth;
      }

      // Si está autenticado
      if (user != null) {
        // Si el perfil no está completo, ir a complete-info
        if (user.profileComplete == false && !isGoingToCompleteInfo) {
          return RouteNames.completeInfo;
        }

        // Si el perfil está completo, redirigir según rol
        if (user.profileComplete == true) {
          if (user.role == 'Admin' && !isGoingToAdmin) {
            return RouteNames.admin;
          }
          if (user.role != 'Admin' && !isGoingToHome) {
            return RouteNames.home;
          }
        }
      }

      return null; // No redirect
    },
    routes: [
      // Root - redirige automáticamente
      GoRoute(
        path: RouteNames.root,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),

      // Onboarding
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Language
      GoRoute(
        path: RouteNames.language,
        builder: (context, state) => const LanguageScreen(),
      ),

      // Auth
      GoRoute(
        path: RouteNames.auth,
        builder: (context, state) => const AuthPage(),
      ),

      // Complete Info
      GoRoute(
        path: RouteNames.completeInfo,
        builder: (context, state) => const CompleteInfoScreen(),
      ),

      // Forgot Password
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const SendEmailScreen(),
      ),

      // Password Success
      GoRoute(
        path: RouteNames.passwordSuccess,
        builder: (context, state) => const SuccessScreen(),
      ),

      // Home (Usuario)
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Admin
      GoRoute(
        path: RouteNames.admin,
        builder: (context, state) => const HomeScreenAdmin(),
      ),
    ],
  );
});
