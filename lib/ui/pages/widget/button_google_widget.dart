import 'package:flutter/material.dart';
class ButtonGoogleWidget extends StatelessWidget {
  const ButtonGoogleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Lógica para autenticación con Google
        print('Autenticación con Google');
      },
      icon: Image.asset(
        'assets/icons/google.png', // Asegúrate de tener el ícono de Google
        height: 24,
        width: 24,
      ),
      label: Text(
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
        minimumSize: Size(double.infinity, 48),
      ),
    );
  }
}
