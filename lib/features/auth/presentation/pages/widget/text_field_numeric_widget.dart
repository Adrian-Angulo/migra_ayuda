import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldNumericWidget extends StatefulWidget {
  final String title;
  final String hintText;

  final TextEditingController controller;

  const TextFieldNumericWidget({
    super.key,
    required this.title,
    required this.hintText,

    required this.controller,
  });

  @override
  State<TextFieldNumericWidget> createState() => _TextFieldNumericWidgetState();
}

class _TextFieldNumericWidgetState extends State<TextFieldNumericWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title),
        TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: widget.controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu edad';
            }
            final age = int.tryParse(value);
            if (age == null || age < 18 || age > 100) {
              return 'Edad debe ser entre 18 y 100 años';
            }
            return null;
          },

          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: widget.hintText,
          ),
        ),
      ],
    );
  }
}
