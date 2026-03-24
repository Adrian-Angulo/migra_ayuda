import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/HomeScreen/home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/AdminHomeScreen/admin_home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/auth_page.dart';

class NavigationService {
  static void navigateByRole(BuildContext context, UserModel user) {
    try {
      final role = _normalizeRole(user.role);

      Widget destination;
      switch (role) {
        case 'Administrador':
          destination = const AdminHomeScreen();
          break;
        case 'Migrante':
        default:
          destination = const HomeScreen();
          break;
      }

      if (!context.mounted) {
        debugPrint('Error: Context no montado, no se puede navegar');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    } catch (e) {
      debugPrint('Error en navegación basada en roles: $e');
      // Fallback seguro a LoginScreen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      }
    }
  }

  static String _normalizeRole(String role) {
    final validRoles = ['Migrante', 'Administrador'];
    if (!validRoles.contains(role)) {
      debugPrint('Role inválido detectado: $role. Normalizando a Migrante');
      return 'Migrante';
    }
    return role;
  }
}
