import 'package:flutter/material.dart';
import 'package:migra_ayuda/provider/auth_provider.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/HomeScreen/home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/admin/home_screen_admin.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/auth_page.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/complete_info_screen.dart';
import 'package:provider/provider.dart';

class ButtonGoogleWidget extends StatelessWidget {
  const ButtonGoogleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final authProvider = context.read<AuthProvider>();

        try {
          await authProvider.logout();
          final profileComplete = await authProvider.handleGoogleLogin();

          if (!context.mounted) return;

          if (authProvider.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error!),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          if (profileComplete == null) return;

          if (!profileComplete) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CompleteInfoScreen(),
              ),
            );
            return;
          }

          final userRole = authProvider.user?.role;
          Widget destinationScreen;

          switch (userRole) {
            case "Admin":
              destinationScreen = const HomeScreenAdmin();
              break;
            case "Migrante":
              destinationScreen = const HomeScreen();
              break;
            default:
              destinationScreen = const AuthPage();
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destinationScreen),
          );
        } catch (e) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error inesperado: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      icon: Image.asset(
        'assets/icons/google.png',
        height: 24,
        width: 24,
      ),
      label: const Text(
        "Continuar con Google",
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}
