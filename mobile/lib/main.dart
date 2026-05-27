import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:migra_ayuda/core/router/app_router.dart';
import 'package:migra_ayuda/core/router/app_router_mobile.dart';
import 'package:migra_ayuda/core/sync/sync_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_sync_provider.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_sync_provider.dart';
import 'package:migra_ayuda/features/language/presentation/providers/language_provider.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';
import 'core/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa Sembast Database
  if (!kIsWeb) {
    try {
      final sembastDb = SembastDatabase.instance;
      await sembastDb.database;
      print('✅ Sembast Database inicializada correctamente');
    } catch (e) {
      print('❌ Error al inicializar Sembast Database: $e');
    }
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Inicializar sync después del primer frame
      Future.microtask(() async {
        final syncService = ref.read(syncServiceProvider);

        try {
          await syncService.initialize();
          print('✅ SyncService inicializado correctamente');
        } catch (e) {
          print('❌ Error al inicializar SyncService: $e');
        }

        // Inicializar sincronización automática
        ref.read(entitySyncInitializerProvider);
        ref.read(reviewSyncInitializerProvider);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final router = ref.watch(routerProvider);
      return MaterialApp.router(
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es')],
        title: 'MigraAyuda Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6FA3A1)),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      );
    } else {
      final mobileRouter = ref.watch(routerMobile);
      final languageAsync = ref.watch(languageProvider);

      return languageAsync.when(
        data: (locale) => MaterialApp.router(
          key: ValueKey(locale?.languageCode ?? 'default'),
          locale: locale ?? const Locale('es'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es'), Locale('en')],
          title: "Migra Ayuda",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Inter',
            useMaterial3: true,
          ),
          routerConfig: mobileRouter,
        ),
        loading: () => const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        error: (error, stack) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error al cargar la aplicación: $error'),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
