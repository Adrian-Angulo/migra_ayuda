import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/login_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Email icon
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF6FA3A1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.email_outlined,
            size: 50,
            color: Color(0xFF6FA3A1),
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          '¡Enlace enviado!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Te hemos enviado un enlace para restablecer tu contraseña. Revisa tu bandeja de entrada y también tu carpeta de spam. Recuerda que el correo debe estar registrado en el sistema',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFE69C),
              width: 1,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF856404),
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Si no encuentras el correo, revisa tu carpeta de spam o correo no deseado.',
                  style: TextStyle(
                    color: Color(0xFF856404),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6FA3A1),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (kIsWeb) {
              context.go('/login');
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            }
          },
          child: const Text(
            'Volver al inicio de sesión',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );

    // Si estamos en web (no mobile), centramos el contenido y limitamos el ancho.
    if (kIsWeb) {
      content = Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
            minWidth: 320,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: content,
        ),
      ),
    );
  }
}
