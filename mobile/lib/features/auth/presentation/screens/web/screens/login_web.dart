import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/core/widgets/snackbar_web_widget.dart';
import 'package:migra_ayuda/core/widgets/snackbar_widget.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/reset_password/send_email_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/widgets/button_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/widgets/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/widgets/text_fiel_widget.dart';

class LoginWeb extends ConsumerStatefulWidget {
  const LoginWeb({super.key});

  @override
  ConsumerState<LoginWeb> createState() => _LoginWebState();
}

class _LoginWebState extends ConsumerState<LoginWeb> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  ProviderSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authSubscription = ref.listenManual<AsyncValue<UserModel?>>(
          authNotifierProvider, (previous, next) {
        next.whenOrNull(
          data: (user) {
            if (previous?.value == user) return;

            if (user == null) return;

            if (!mounted) return;

            final role = user.role ?? '';
            if (role != "Admin") {
              SnackbarWebWidget.info(
                  context, '¡No Tienes permiso de administrador!');

              ref.read(authNotifierProvider.notifier).logout();
              if (!mounted) return;
              context.go(Routes.login);
            } else {
              if (!mounted) return;
              context.go(Routes.dashboard);
            }
          },
          error: (error, stackTrace) {
            SnackbarWebWidget.error(context, error.toString());
          },
        );
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.close();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  void _cleanControllers() {
    emailController.clear();
    passController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    final authState = ref.watch(authNotifierProvider);
    final horizontalPadding = isDesktop ? 36.0 : (isWide ? 28.0 : 20.0);

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
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Gestiona y supervisa todos los recursos de MigraAyuda desde un solo lugar.",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
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
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        isDesktop ? 420 : (isWide ? 480 : double.infinity),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 0 : horizontalPadding,
                      vertical: 40,
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
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 40,
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "Bienvenido",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Inicia sesión para continuar",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  TextFieldWidget(
                                    title: "Correo",
                                    hintText: "ejemplo@gmail.com",
                                    controller: emailController,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
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
                                      if (value == null ||
                                          value.trim().isEmpty) {
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
                                          /*  context.push(
                                            Routes.sendEmail,
                                          ); */
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
                                        final email = emailController.text;
                                        final password = passController.text;
                                        await ref
                                            .read(authNotifierProvider.notifier)
                                            .login(email, password);
                                        final state =
                                            ref.read(authNotifierProvider);
                                        final loginSucceeded = state.hasValue &&
                                            state.value != null &&
                                            !state.hasError;

                                        if (loginSucceeded) {
                                          _cleanControllers();
                                        }
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
            ),
          ),
        ],
      ),
    );
  }
}
