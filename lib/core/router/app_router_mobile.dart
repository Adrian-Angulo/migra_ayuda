import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/presentation/screens/splash_screen.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/features/splash_init/splash_init.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/login_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/complete_info_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/register_screen.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/home_card_screen.dart';
import 'package:migra_ayuda/features/language/presentation/providers/language_provider.dart';
import 'package:migra_ayuda/features/language/presentation/screens/language_screen.dart';
import 'package:migra_ayuda/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:migra_ayuda/features/onboarding/presentation/screens/onboarding_screen.dart';

class RouterMovilNotifier extends ChangeNotifier {
  static final RouterMovilNotifier _instance = RouterMovilNotifier._internal();

  factory RouterMovilNotifier() => _instance;

  RouterMovilNotifier._internal();

  void refresh() {
    notifyListeners();
  }
}

final routerMovilNotifierProvider = Provider<RouterMovilNotifier>(
  (ref) => RouterMovilNotifier(),
);

final routerMobile = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: Routes.splashInit,
      refreshListenable: ref.read(routerMovilNotifierProvider),
      redirect: (context, state) {
        final languageAsync = ref.read(languageProvider);
        final seeOnboarding = ref.read(onboardingProvider);
        final authAsync = ref.read(authNotifierProvider);

        // Si estamos en splashInit o splash, no redirigir
        if (state.matchedLocation == Routes.splashInit) return null;

        /*  // Esperar a que los providers terminen de cargar
        final isLoading = languageAsync.isLoading ||
            seeOnboarding.isLoading ||
            authAsync.isLoading;
        if (isLoading) return Routes.splash; */

        // Si no hay idioma seleccionado, ir a selección de idioma
        final hasNoLanguage =
            languageAsync.value == null || languageAsync.hasError;
        if (hasNoLanguage) return Routes.selectLanguaje;

        // Si el usuario no ha visto el onboarding, mostrarlo
        final hasNotSeenOnboarding =
            seeOnboarding.value == false || seeOnboarding.hasError;
        if (hasNotSeenOnboarding) return Routes.onboarding;

        // Si no hay sesión activa, ir al login
        final user = authAsync.value;

        if (user == null) return Routes.loginMovil;

        // Si el perfil está incompleto, solicitar completarlo
        if (!user.profileComplete) return Routes.completeProfile;

        // Redirigir según el rol del usuario
        if (user.role == 'Migrante') return Routes.home;

        return null;
      },
      routes: [
        GoRoute(
          path: Routes.splashInit,
          builder: (context, state) => const FadeIn(
              duration: Duration(seconds: 2), child: SplashScreenInit()),
        ),
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
          builder: (context, state) => const FadeIn(
            duration: Duration(seconds: 2),
            child: LoginScreen()),
        ),
        GoRoute(
          path: Routes.registerMovil,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) => HomeCardScreen(),
        ),
        GoRoute(
          path: Routes.completeProfile,
          builder: (context, state) => const CompleteInfoScreen(),
        ),
      ],
    );
  },
);
