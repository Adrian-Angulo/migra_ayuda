import 'package:flutter/material.dart';
import 'package:migra_ayuda/provider/auth_provider.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/HomeScreen/home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/admin/home_screen_admin.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/widget/button_google_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/widget/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/widget/text_fiel_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/recuperar_contrase%C3%B1a/send_email_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/button_widget.dart';
import 'package:provider/provider.dart';

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
    final autProvider = context.read<AuthProvider>();
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
            text: 'Iniciar Sesión',
            loading: context.watch<AuthProvider>().isLoading,
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await autProvider.logout();
                await autProvider.login(
                    emailController.text, passController.text);
                if (!context.mounted) return;

                if (autProvider.error == null) {
                  emailController.clear();
                  passController.clear();

                  switch (autProvider.user?.role) {
                    case "Admin":
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreenAdmin()));
                      break;
                    case 'Migrante':
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                      break;
                    default:
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("error"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      const Duration(seconds: 3);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Scaffold(
                                    body: Center(
                                      child: Text("algo salio mal"),
                                    ),
                                  )));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(autProvider.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
          const Row(
            spacing: 20,
            children: [
              Expanded(child: Divider(height: 2)),
              Text("O"),
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
