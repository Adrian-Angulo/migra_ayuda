import 'package:flutter/material.dart';


class ButtonGoogleWidget extends StatelessWidget {
  const ButtonGoogleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        
      },
      icon: Image.asset(
        'assets/icons/google.png',
        height: 24,
        width: 24,
      ),
      label: const Text(
        "Continuar con Google",
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}
