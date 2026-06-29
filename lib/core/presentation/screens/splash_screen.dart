import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla de splash con sincronización inicial
/// Muestra un loading mientras descarga todos los datos de Firebase.
/// Una vez completada la sincronización, navega automáticamente al home.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /* final syncAsync = ref.watch(initialSyncProvider); */

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de la app
              Image.asset(
                'assets/logo/Logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 32),

              // Indicador de carga
              const CircularProgressIndicator(
                color: Color(0xFF5F9EA0),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),

              // Texto de sincronización
              const Text(
                'Cargando',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              /* const SizedBox(height: 8),
                const Text(
                  'Por favor espera',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ), */
            ],
          ),
        ),
      ),
    );
  }
}
