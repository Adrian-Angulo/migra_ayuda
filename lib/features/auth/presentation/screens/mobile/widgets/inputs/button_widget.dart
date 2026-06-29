import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.text,
    this.onPressed,
    this.loading = false,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading
          ? null
          : (onPressed ??
              () {
                if (_formKey.currentState!.validate()) {}
              }),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: loading
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            )
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
    );
  }
}
