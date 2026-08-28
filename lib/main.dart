import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:migra_ayuda/core/config/loadToken.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/router/app_router.dart';
import 'package:migra_ayuda/core/router/app_router_mobile.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';
import 'core/config/firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy();
  if (!kIsWeb) {
    await Loadtoken.setup(); //preparar token de mapa
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(kIsWeb ? routerProvider : routerMobile);

    return MaterialApp.router(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es')],
      title: "Migra Ayuda",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: ColorConstants.background,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
