import 'package:flutter/material.dart';
import 'package:migra_ayuda/provider/auth_provider.dart';
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
        await authProvider.handleGoogleLogin(context);
        if (!context.mounted) return;
        if (authProvider.error != null) {
          // Error en la autenticación
          print(authProvider.error);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  authProvider.error ?? 'Error al iniciar sesión con Google'),
              backgroundColor: Colors.red,
            ),
          );
        }
        
      },
      icon: Image.asset(
        'assets/icons/google.png', // Asegúrate de tener el ícono de Google
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


