
import 'package:flutter/material.dart';

class HeaderFormAuth extends StatelessWidget {
  const HeaderFormAuth({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/logo/Fondo.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'app-logo',
                child: Image.asset(
                  'assets/logo/Logo.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Image.asset(
                "assets/logo/MigraAyuda.png",
                width: 180,
              ),
              const SizedBox(height: 20),
              Text(
                "Crear Cuenta",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B1B1B),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                "Únete a MigraAyuda y accede a sus recursos",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
