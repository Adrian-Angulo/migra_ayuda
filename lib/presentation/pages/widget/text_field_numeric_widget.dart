import 'package:flutter/material.dart';

class TextFieldNumericWidget extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const TextFieldNumericWidget({
    super.key,
    required this.title,
    required this.hintText,
    
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        TextFormField(
          controller: controller,
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu edad';
                }
                final age = int.tryParse(value);
                if (age == null || age < 18 || age > 100) {
                  return 'Edad debe ser entre 18 y 100 años';
                }
                return null;
              },
          keyboardType: TextInputType.number,
          maxLength: 2,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: hintText,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
