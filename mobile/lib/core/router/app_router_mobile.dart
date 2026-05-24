import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/presentation/screens/splash_screen.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/auth_page.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/complete_info_screen.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/explore_screen.dart';
import 'package:migra_ayuda/features/language/presentation/providers/language_provider.dart';
import 'package:migra_ayuda/features/language/presentation/screens/language_screen.dart';
import 'package:migra_ayuda/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:migra_ayuda/features/onboarding/presentation/screens/onboarding_screen.dart';

final routerMobile = Provider<GoRouter>(
  (ref) {
    final languageAsync = ref.watch(languageProvider);
    final seeOnboarding = ref.watch(onboardingProvider);
    final authAsync = ref.watch(authNotifierProvider);

    return GoRouter(
      initialLocation: Routes.splash,
      redirect: (context, state) {
        final currentPath = state.matchedLocation;

        if (languageAsync.isLoading || seeOnboarding.isLoading) {
          return Routes.splash;
        }
        if (languageAsync.value == null || languageAsync.hasError) {
          return Routes.selectLanguaje;
        }

        if (seeOnboarding.value == false || seeOnboarding.hasError) {
          return Routes.onboarding;
        }

        if (authAsync.value == null) {
          return Routes.loginMovil;
        }

        if (authAsync.value!.profileComplete == false) {
          return Routes.completeProfile;
        }

        if (authAsync.value?.role == "Migrante") {
          return Routes.home;
        }

        return Routes.loginMovil;
      },
      routes: [
        GoRoute(
          path: Routes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.selectLanguaje,
          builder: (context, state) => const LanguageScreen(),
        ),
        GoRoute(
          path: Routes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: Routes.loginMovil,
          builder: (context, state) => const AuthPage(),
        ),
        GoRoute(
            path: Routes.home,
            builder: (context, state) => const ExploreScreen()),
        GoRoute(
          path: Routes.completeProfile,
          builder: (context, state) => const CompleteInfoScreen(),
        )
      ],
    );
  },
);
