import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/edit_profile_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/drawer/drawer_menu_items.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/drawer/drawer_user_header.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header con información del usuario
            const DrawerUserHeader(
              userName: "Adrian Angulo",
              userEmail: "adrianangulo1080@gmail.com",
              origin: "México",
              destination: "España",
              age: "28 años",
            ),

            // Opciones del menú
            Expanded(
              child: DrawerMenuItems(
                onEditProfile: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
                onLogout: () async {
                  Navigator.pop(context);
                  await ref.read(authNotifierProvider.notifier).logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
