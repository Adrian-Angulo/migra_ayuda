import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/errors/error_mappers.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/complete_info_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/register_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/reset_password/send_email_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/button_google_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/button_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_password_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/register_card.dart';

// Pantalla principal de autenticación que alterna entre login y registro
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String? selectedCountry;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Escucha cambios en el estado de autenticación para reaccionar
    // cuando el usuario inicia sesión correctamente o hay un error
    ref.listen(
      authNotifierProvider,
      (previous, next) {
        next.whenOrNull(data: (user) async {
          if (user != null) {
            if (user.role == 'Migrante') {
              // Registra la actividad de inicio de sesión en la auditoría

              if (!context.mounted) return;
              // Redirige según el estado del perfil y el rol del usuario
              if (user.profileComplete == false) {
                // El usuario aún no ha completado su perfil
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompleteInfoScreen(),
                    ));
              }
            } else {
              // Usuario NO es Migrante (Admin u otro rol)
              if (!context.mounted) return;
              // Mostrar mensaje de error
              SnackbarWidget.info(
                  context, '¡Eres administrador, ingresa al panel web!');

              // Esperar 2 segundos para que el usuario vea el mensaje
              await Future.delayed(const Duration(seconds: 2));

              // Hacer logout después de mostrar el mensaje
              if (context.mounted) {
                await ref.read(authNotifierProvider.notifier).logout();
              }
            }
          }
        }, error: (error, stackTrace) {
          // Muestra el error de autenticación en un snackbar
          SnackbarWidget.error(context,
              ErrorMappers.getAuthErrorMessage(error.toString(), context));
        });
      },
    );

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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/logo/Fondo.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'app-logo',
                              child: Image.asset(
                                'assets/logo/Logo.png',
                                width: 110,
                                height: 110,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Hero(
                              tag: 'app-logo2',
                              child: Image.asset(
                                'assets/logo/MigraAyuda.png',
                                width: 180,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "¡Bienvenido!",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1B1B1B),
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Tu guía para migrar comienza aqui.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: const Color(0xFF0B8A6D),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Inicia sesión para continuar",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        TextFieldWidget(
                          title: 'Correo electrónico',
                          hintText: "correo@ejemplo.com",
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El correo es obligatorio';
                            }
                            final emailRegex =
                                RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFieldPaswordWidget(
                          title: 'Contraseña',
                          controller: passController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La contraseña es obligatoria';
                            }
                            if (value.length < 8) {
                              return 'La contraseña debe tener al menos 8 caracteres';
                            }

                            return null;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SendEmailScreen(),
                                    ));
                              },
                              child: const Text('¿Olvidaste tu contraseña?'),
                            ),
                          ],
                        ),
                        ButtonWidget(
                          formKey: formKey,
                          loading: authState.isLoading,
                          text: 'Iniciar Sesión',
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .login(emailController.text,
                                      passController.text);
                              /* cleanControllar(); */
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            Expanded(child: Divider(height: 2)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text("O continúa con"),
                            ),
                            Expanded(child: Divider(height: 2)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const ButtonGoogleWidget(),
                        const SizedBox(
                          height: 16,
                        ),
                        RegisterCard(onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ));
                        })
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
