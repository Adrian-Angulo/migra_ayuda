import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "HomeScreen. pantalla principal para iniciar con la navegacion de dasboard y servicios",
        ),
      ),
    );
  }
}
