import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/utils/widgets/mensajesWidget.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/reset_password_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/recuperar_contraseña/success_screen.dart';

class SendEmailScreen extends ConsumerStatefulWidget {
  const SendEmailScreen({super.key});

  @override
  ConsumerState<SendEmailScreen> createState() => _SendEmailScreenState();
}

class _SendEmailScreenState extends ConsumerState<SendEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await ref
        .read(resetPasswordProvider.notifier)
        .resetPassword(_emailController.text);

    setState(() => _isLoading = false);
/*     Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SuccessScreen(),
      ),
    ); */
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      resetPasswordProvider,
      (previous, next) {
        next.whenOrNull(
          data: (data) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SuccessScreen(),
              ),
            );
          },
          error: (error, stackTrace) {
            Mensajeswidget.mostrarError(context, error.toString());
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Image.asset(
                    'assets/logo_login.png',
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6FA3A1).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          size: 50,
                          color: Color(0xFF6FA3A1),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "¿Olvidaste tu contraseña?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Introduce tu correo para recibir un enlace y restablecer tu contraseña",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  // Label del campo
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Correo electrónico",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Campo de correo con validación
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: "migraAyuda@correo.com",
                      filled: true,
                      fillColor: const Color(0xFFFFFFFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6FA3A1),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo electrónico';
                      }

                      // Validación de formato mejorada
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );

                      if (!emailRegex.hasMatch(value)) {
                        return 'Formato de correo inválido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FA3A1),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Enviar enlace",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Volver al inicio de sesión con flecha
                  TextButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.popUntil(
                            context, (route) => route.isFirst),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: Colors.grey,
                    ),
                    label: const Text(
                      "Volver al inicio de sesión",
                      style: TextStyle(color: Colors.grey),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
