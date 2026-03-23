import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/utils/constants.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/login_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/register_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/switch_button.dart';


enum AuthMode { login, register }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String? selectedCountry;
  AuthMode mode = AuthMode.login;

  @override
  Widget build(BuildContext context) {
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
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/logo/Logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Text(
                        "Comenzar ahora",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Completa tus datos para crear una cuenta",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(108, 114, 120, 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  // -----------------botones iniciar session y registro-------------
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
                            text: "Iniciar sesión",
                            isActive: mode == AuthMode.login,
                            onTap: () => setState(() {
                              mode = AuthMode.login;
                            }),
                          ),
                        ),
                        Expanded(
                          child: SwitchButton(
                              text: "Registrarse",
                              isActive: mode == AuthMode.register,
                              onTap: () => setState(() {
                                    mode = AuthMode.register;
                                  })),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  mode == AuthMode.login
                      ? const LoginScreen()
                      : const RegisterScreen(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
