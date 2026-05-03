import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:migra_ayuda/core/providers/location_provider.dart';
import 'package:migra_ayuda/core/sync/sync_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_sync_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/explorar_screen.dart';
import 'package:migra_ayuda/features/language/presentation/providers/language_provider.dart';
import 'package:migra_ayuda/features/onboarding/presentation/screens/start_page.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';
import 'core/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa Sembast Database
  try {
    final sembastDb = SembastDatabase.instance;
    await sembastDb.database;
    print('✅ Sembast Database inicializada correctamente');
  } catch (e) {
    print('❌ Error al inicializar Sembast Database: $e');
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
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);

    // Inicializa el SyncService cuando la app arranca
    ref.listen(syncServiceProvider, (previous, next) {
      next.initialize().then((_) {
        print('✅ SyncService inicializado correctamente');
      }).catchError((error) {
        print('❌ Error al inicializar SyncService: $error');
      });
    });

    // Inicializa la sincronización automática de entidades
    ref.watch(entitySyncInitializerProvider);

    // Escucha cambios de conectividad para mostrar feedback al usuario
    ref.listen(connectionStatusProvider, (previous, next) {
      next.when(
        data: (isConnected) {
          if (isConnected) {
            print('🌐 Conexión a internet detectada');
          } else {
            print('📵 Sin conexión a internet - Modo offline');
          }
        },
        loading: () {},
        error: (err, stack) => print('Error en conectividad: $err'),
      );
    });

    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
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
      /* home: const StartPage(), */
      home: ExplorarScreen(),
    );
  }
}
