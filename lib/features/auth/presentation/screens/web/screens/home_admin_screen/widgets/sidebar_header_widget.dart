import 'package:flutter/material.dart';

class SidebarHeaderWidget extends StatelessWidget {
  const SidebarHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              IconButton(
                onPressed: () {
                  // TODO: Cerrar sidebar en mobile
                },
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Logo circular
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/logo/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'MigraAyuda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sistema de Gestión',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
