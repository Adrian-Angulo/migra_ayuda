import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/sync/sync_providers.dart';
import 'package:migra_ayuda/features/onboarding/presentation/screens/start_page.dart';

/// Pantalla de splash con sincronización inicial
///
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
    final syncAsync = ref.watch(initialSyncProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: syncAsync.when(
          data: (syncResult) {
            // Sincronización completada, navegar a home
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StartPage(),
                    ));
              }
            });

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF059669),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    syncResult.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
          loading: () => Column(
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
                'Sincronizando datos...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor espera',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono de error
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 64,
                ),
                const SizedBox(height: 16),

                // Título de error
                const Text(
                  'Error al sincronizar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 8),

                // Mensaje de error
                Text(
                  error.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de reintentar
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(initialSyncProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F9EA0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Botón de continuar sin sincronizar (si ya se sincronizó antes)
                Consumer(
                  builder: (context, ref, child) {
                    final hasSynced = ref.watch(hasSyncedProvider);
                    if (!hasSynced) return const SizedBox.shrink();

                    return TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: const Text(
                        'Continuar sin sincronizar',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
