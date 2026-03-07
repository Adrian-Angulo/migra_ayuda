import 'package:flutter/material.dart';
import 'package:migra_ayuda/ui/pages/login_screen.dart';
import 'package:migra_ayuda/ui/pages/register_screen.dart';
import 'package:migra_ayuda/ui/pages/widget/login_register_switcher.dart';
import 'package:migra_ayuda/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  

  String? selectedCountry;

  @override
  Widget build(BuildContext context) {
    final isSelected = context.watch<AuthProvider>().isSelected;
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
                  const SizedBox(height: 16),
                  // -----------------botones iniciar session y registro-------------
                  const LoginRegisterSwitcher(),
                  const SizedBox(height: 16),
                  isSelected ? const LoginScreen() : const RegisterScreen(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
