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



final routerMovilNotifierProvider = Provider<RouterMovilNotifier>(
  (ref) => RouterMovilNotifier(),
);


final routerMobile = Provider<GoRouter>(
  (ref) {
  
    final notifier = ref.watch(appRouterNotifierProvider);

   
    return GoRouter(
      initialLocation: Routes.splashInit, 
      refreshListenable: notifier, 
      redirect: (context, state) => mobileRedirectGuard(context, state, ref), 
      routes: [
       
        GoRoute(
          path: Routes.splashInit,
          builder: (context, state) => const FadeIn(
            duration: Duration(seconds: 2),
            child: SplashScreenInit(),
          ),
        ),
       
        GoRoute(
          path: Routes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
       
        GoRoute(
          path: Routes.loginMovil,
          builder: (context, state) => const LoginScreen(),
        ),
       
        GoRoute(
          path: Routes.registerMovil,
          builder: (context, state) => const RegisterScreen(),
        ),
       
        GoRoute(
          path: Routes.home,
          builder: (context, state) => HomeScreen(),
        ),
        
        GoRoute(
          path: Routes.completeProfile,
          builder: (context, state) => const CompleteInfoScreen(),
        ),
        
        GoRoute(
          path: Routes.resetPassword,
          builder: (context, state) => const SendEmailScreen(),
        )
      ],
    );
  },
);
