import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';

import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/widgets/snackbar_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/explorar_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/complete_info_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/login_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/register_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/switch_button.dart';

import 'package:migra_ayuda/features/userActivity/presentation/providers/create_activity_notifier.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

// Define los dos modos posibles de la pantalla: inicio de sesión o registro
enum AuthMode { login, register }

// Pantalla principal de autenticación que alterna entre login y registro
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  String? selectedCountry;

  // Modo activo por defecto al abrir la pantalla
  AuthMode mode = AuthMode.login;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    // Escucha cambios en el estado de autenticación para reaccionar
    // cuando el usuario inicia sesión correctamente o hay un error
/*     ref.listen(
      authNotifierProvider,
      (previous, next) {
        next.whenOrNull(data: (user) async {
          if (user != null) {
            if (user.role == 'Migrante') {
              // Registra la actividad de inicio de sesión en la auditoría
              await ref.read(createActivityNotifier.notifier).createActivity(
                  user: user.id,
                  accion: ActivityActions.login(),
                  nombre: user.name,
                  correo: user.email,
                  pais: user.originCountry!);

              if (!context.mounted) return;
              // Redirige según el estado del perfil y el rol del usuario
              if (user.profileComplete == false) {
                // El usuario aún no ha completado su perfil
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompleteInfoScreen(),
                    ));
              } else {
                // Usuario regular va a la pantalla principal
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExplorarScreen(),
                    ));
              }
            } else if (user.role != "Migrante") {
              await ref.read(authNotifierProvider.notifier).logout();
              SnackbarWidget.info(
                  context, "¡Eres administrador, ingresa al panel web!");
            }
          }
        }, error: (error, stackTrace) {
          // Muestra el error de autenticación en un snackbar
          SnackbarWidget.error(context, error.toString());
        });
      },
    );
 */
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Sección del encabezado: logo y texto de bienvenida
                  Column(
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      Image.asset(
                        'assets/logo/Logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        "assets/logo/MigraAyuda.png",
                        width: 200,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        l10n.authWelcomeText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(108, 114, 120, 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  // Botones para alternar entre "Iniciar sesión" y "Registro"
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SwitchButton(
                            text: l10n.loginTab,
                            isActive: mode == AuthMode.login,
                            // Cambia el modo a login al presionar
                            onTap: () => setState(() {
                              mode = AuthMode.login;
                            }),
                          ),
                        ),
                        Expanded(
                          child: SwitchButton(
                              text: l10n.registerTab,
                              isActive: mode == AuthMode.register,
                              // Cambia el modo a registro al presionar
                              onTap: () => setState(() {
                                    mode = AuthMode.register;
                                  })),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Muestra el formulario correspondiente según el modo activo
                  if (mode == AuthMode.login)
                    const LoginScreen()
                  else
                    const RegisterScreen(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
