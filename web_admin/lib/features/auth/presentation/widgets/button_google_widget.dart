import 'package:flutter/material.dart';

class ButtonGoogleWidget extends StatelessWidget {
  const ButtonGoogleWidget({
    super.key,
    required this.onPressed,
    this.label = 'Continuar con Google',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset('assets/icons/google.png', height: 24, width: 24),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}
