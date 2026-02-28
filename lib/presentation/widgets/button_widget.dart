import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.acceptTerms,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final bool acceptTerms;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate() && acceptTerms) {
          
        } else if (!acceptTerms) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Debes aceptar los términos y condiciones'),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: Size(double.infinity, 48),
      ),
      child: Text(
        "Registrarse",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
