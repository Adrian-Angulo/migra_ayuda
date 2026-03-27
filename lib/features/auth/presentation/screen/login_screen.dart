import 'package:flutter/material.dart';

import 'package:migra_ayuda/features/auth/presentation/screen/recuperar_contrase%C3%B1a/send_email_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/button_google_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/button_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/text_fiel_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool _isLoading = false;

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
  Widget build(
    BuildContext context,
  ) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFieldWidget(
            title: "Correo electronico",
            hintText: "Ej. usuario@gmail.com",
            controller: emailController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El correo es obligatorio';
              }
              final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Ingresa un correo válido';
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
                        builder: (context) => const SendEmailScreen(),
                      ));
                },
                child: const Text("¿Olvidaste tu contraseña?"),
              ),
            ],
          ),
          ButtonWidget(
            formKey: formKey,
            loading: _isLoading,
            text: 'Iniciar Sesión',
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                setState(() => _isLoading = true);
                try {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                        const SnackBar(content: Text("Ha iniciado session")));
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(SnackBar(content: Text("$error")));
                  }
                } finally {
                  setState(() => _isLoading = false);
                }
                cleanControllar();
              }
            },
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider(height: 2)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("O"),
              ),
              Expanded(child: Divider(height: 2)),
            ],
          ),
          const SizedBox(height: 16),
          const ButtonGoogleWidget(),
        ],
      ),
    );
  }
}
