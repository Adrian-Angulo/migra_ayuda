import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/services/navigation_service.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/complete_info_screen.dart';

class ButtonGoogleWidget extends ConsumerWidget {
  const ButtonGoogleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          final isFirstTime =
              await ref.read(authProvider.notifier).authWithGoogle();

          if (!context.mounted) return;

          if (isFirstTime) {
            // Primera vez - ir a completar información
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CompleteInfoScreen(),
              ),
            );
          } else {
            // Usuario existente - navegar según rol
            final user = ref.read(authProvider).value;
            if (user != null) {
              NavigationService.navigateByRole(context, user);
            }
          }
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
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
