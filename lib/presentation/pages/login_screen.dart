import 'package:flutter/material.dart';
import 'package:migra_ayuda/presentation/pages/widget/button_google_widget.dart';
import 'package:migra_ayuda/presentation/pages/widget/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda/presentation/pages/widget/text_fiel_widget.dart';
import 'package:migra_ayuda/presentation/widgets/button_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFieldWidget(
            title: "Correo electronico",
            hintText: "Ej. usuario@gmail.com",
            controller: emailController,
          ),
          const SizedBox(height: 16),
          TextFieldPaswordWidget(
            title: "Contraseña",
            controller: passController,
          ),
          const SizedBox(height: 16),
          ButtonWidget(formKey: formKey, text: 'Iniciar Sesión'),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider(height: 2)),
              Text("O Registrase con"),
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
