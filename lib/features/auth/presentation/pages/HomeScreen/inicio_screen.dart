import 'package:flutter/material.dart';

class InicioScreen extends StatelessWidget {
  final String userName;

  const InicioScreen({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Bienvenido al inicio',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}