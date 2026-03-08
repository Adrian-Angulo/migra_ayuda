import 'package:flutter/material.dart';
import 'screen/recuperar_contraseña/recuperar_contrasena_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Migra Ayuda",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ForgotPasswordScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
