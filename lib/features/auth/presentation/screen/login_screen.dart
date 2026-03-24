import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/services/navigation_service.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/recuperar_contrase%C3%B1a/send_email_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/button_google_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/button_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/text_fiel_widget.dart';

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
  Widget build(
    BuildContext context,
  ) {
    final authState = ref.watch(authProvider);
    final auth = ref.read(authProvider.notifier);

    ref.listen(
      authProvider,
      (previous, next) {
        next.whenOrNull(
          data: (user) {
            if (user != null && context.mounted) {
              NavigationService.navigateByRole(context, user);
            }
          },
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text("$error")));
          },
        );
      },
    );

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
            loading: authState.isLoading,
            text: 'Iniciar Sesión',
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await auth.login(emailController.text, passController.text);
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
