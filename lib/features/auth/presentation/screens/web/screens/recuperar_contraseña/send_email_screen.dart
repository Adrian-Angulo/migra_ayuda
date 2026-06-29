/* import 'package:flutter/material.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/screens/recuperar_contrase%C3%B1a/success_screen.dart';

class SendEmailScreen extends StatefulWidget {
  const SendEmailScreen({super.key});

  @override
  State<SendEmailScreen> createState() => _SendEmailScreenState();
}

class _SendEmailScreenState extends State<SendEmailScreen> {
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuccessScreen()),
    );
    setState(() => _isLoading = true);
    // TODO: implement reset password logic
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 0 : 24,
              vertical: 40,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: EdgeInsets.all(isWide ? 48 : 24),
                decoration: isWide
                    ? BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      )
                    : null,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/logo_login.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF6FA3A1,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.help_outline,
                              size: 40,
                              color: Color(0xFF6FA3A1),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Restablecer contraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Ingresa tu correo electrónico para restablecer tu contraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Label
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Correo electrónico',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          hintText: 'ejemplo@correo.com',
                          hintStyle: const TextStyle(color: Color(0xFFB0B7C3)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFD1D5DB),
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFD1D5DB),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF6FA3A1),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo electrónico';
                          }

                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );

                          if (!emailRegex.hasMatch(value)) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6FA3A1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading ? null : handleSubmit,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Enviar enlace',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              ),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        label: const Text(
                          'Volver al inicio de sesión',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

 */