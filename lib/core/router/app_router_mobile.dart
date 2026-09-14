import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:migra_ayuda/core/router/app_router_notifier.dart';
import 'package:migra_ayuda/core/router/guards/mobile_redirect_guard.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/core/widgets/mobil/splash_init.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/login_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/complete_info_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/register_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/reset_password/send_email_screen.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/home_screen.dart';
import 'package:migra_ayuda/features/onboarding/presentation/screens/onboarding_screen.dart';


class RouterMovilNotifier extends ChangeNotifier {
  static final RouterMovilNotifier _instance = RouterMovilNotifier._internal();

  factory RouterMovilNotifier() => _instance;

  RouterMovilNotifier._internal();

  void refresh() {
    notifyListeners();
  }
}


// Proveedor para RouterMovilNotifier, permite actualizar la navegación desde providers/notifiers Riverpod
final routerMovilNotifierProvider = Provider<RouterMovilNotifier>(
  (ref) => RouterMovilNotifier(),
);

// Proveedor de GoRouter configurado para la app móvil
final routerMobile = Provider<GoRouter>(
  (ref) {
    // Observa cambios del notificador de router
    final notifier = ref.watch(appRouterNotifierProvider);

    // Configuración de las rutas principales
    return GoRouter(
      initialLocation: Routes.splashInit, // Ruta inicial al abrir la app
      refreshListenable: notifier, // El router se actualizará si notifier notifica cambios
      redirect: (context, state) => mobileRedirectGuard(context, state, ref), // Redirección basada en lógica de guardas
      routes: [
        // Ruta pantalla Splash, con animación de FadeIn
        GoRoute(
          path: Routes.splashInit,
          builder: (context, state) => const FadeIn(
            duration: Duration(seconds: 2),
            child: SplashScreenInit(),
          ),
        ),
        // Ruta de pantalla de Onboarding (presentación inicial)
        GoRoute(
          path: Routes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        // Ruta de Login
        GoRoute(
          path: Routes.loginMovil,
          builder: (context, state) => const LoginScreen(),
        ),
        // Ruta de Registro de usuario
        GoRoute(
          path: Routes.registerMovil,
          builder: (context, state) => const RegisterScreen(),
        ),
        // Ruta de pantalla principal (Home)
        GoRoute(
          path: Routes.home,
          builder: (context, state) => HomeScreen(),
        ),
        // Ruta para completar el perfil de usuario
        GoRoute(
          path: Routes.completeProfile,
          builder: (context, state) => const CompleteInfoScreen(),
        ),
        // Ruta para el proceso de recuperación de contraseña
        GoRoute(
          path: Routes.resetPassword,
          builder: (context, state) => const SendEmailScreen(),
        )
      ],
    );
  },
);
