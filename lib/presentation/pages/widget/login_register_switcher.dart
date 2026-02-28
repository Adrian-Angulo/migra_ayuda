import 'package:flutter/material.dart';
import 'package:migra_ayuda/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginRegisterSwitcher extends StatelessWidget {
  const LoginRegisterSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final isSelected = context.watch<AuthProvider>().isSelected;

    return Container(
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
            child: _SwitchButton(
              text: "Iniciar sesión",
              isActive: isSelected,
              onTap: () => context.read<AuthProvider>().isSelected = true,
            ),
          ),
          Expanded(
            child: _SwitchButton(
              text: "Registrarse",
              isActive: !isSelected,
              onTap: () => context.read<AuthProvider>().isSelected = false,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _SwitchButton({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal[300] : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
