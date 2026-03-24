import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/admin/home_screen_admin.dart';

import 'package:migra_ayuda/features/auth/presentation/pages/auth_page.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/HomeScreen/home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/AdminHomeScreen/admin_home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: authState.when(
        data: (user) {
          if (user == null) {
            return const AuthPage();
          }
          // Usuario autenticado - navegar según rol
          return _getHomeScreenByRole(user.role);
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const AuthPage(),
      ),
    );
  }

  Widget _getHomeScreenByRole(String role) {
    const validRoles = ['Migrante', 'Administrador'];
    final normalizedRole = validRoles.contains(role) ? role : 'Migrante';

    return normalizedRole == 'Administrador'
        ? const HomeScreenAdmin()
        : const HomeScreen();
  }
}
