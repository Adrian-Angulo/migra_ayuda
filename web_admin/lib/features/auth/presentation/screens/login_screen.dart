import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda_administracion/core/router/routes.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/providers/auth_notifier.dart';

import 'package:migra_ayuda_administracion/features/auth/presentation/screens/recuperar_contraseña/send_email_screen.dart';

import 'package:migra_ayuda_administracion/features/auth/presentation/widgets/button_widget.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/widgets/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/widgets/text_fiel_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  void cleanControllar() {
    emailController.clear();
    passController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWide = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (previous?.value == user) return;

          // 🔴 No logueado → no hacer nada aquí
          if (user == null) return;

          if (user.role != "Admin") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                width: 400,
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                content: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "No tienes permisos de administrador",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
            ref.read(authNotifierProvider.notifier).logout();
            context.go(Routes.login);
          } else {
            context.go(Routes.dashboard);
          }
        },

        error: (error, stackTrace) {
          if (previous?.hasError == true) return;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: Text(error.toString()),
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 21, 192, 69),
                      Color(0xFF42A5F5),
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/logo/logo.png",
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),
                        Image.asset(
                          "assets/logo/MigraAyuda.png",
                          height: 56,
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "Panel de Administración",
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Gestiona y supervisa todos los recursos de MigraAyuda desde un solo lugar.",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: isDesktop ? 4 : 1,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 420 : (isWide ? 480 : double.infinity),
                  minHeight: isDesktop ? screenHeight : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isDesktop) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/logo/logo.png",
                              height: 72,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Image.asset(
                              "assets/logo/MigraAyuda.png",
                              height: 36,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ],
                    Card(
                      elevation: isDesktop ? 10 : 4,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: isDesktop
                            ? BorderSide(color: Colors.grey.shade200)
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 40,
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Bienvenido",
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Inicia sesión para continuar",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              TextFieldWidget(
                                title: "Correo",
                                hintText: "ejemplo@gmail.com",
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "El correo es requerido";
                                  }
                                  final emailRegex = RegExp(
                                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return "El correo no es válido";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFieldPaswordWidget(
                                title: "Contraseña",
                                controller: passController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "La contraseña es requerida";
                                  }
                                  if (value.length < 8) {
                                    return "La contraseña debe tener al menos 8 caracteres";
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
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "¿Olvidaste tu contraseña?",
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ButtonWidget(
                                formKey: formKey,
                                loading: authState.isLoading,
                                text: "Iniciar sesión",
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    await ref
                                        .read(authNotifierProvider.notifier)
                                        .login(
                                          emailController.text,
                                          passController.text,
                                        );

                                    cleanControllar();
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
