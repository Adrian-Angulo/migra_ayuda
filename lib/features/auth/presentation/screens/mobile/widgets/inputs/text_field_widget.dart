import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final String title;
  final String hintText;

  final TextEditingController controller;
  final String? Function(String?)? validator;

  const TextFieldWidget({
    super.key,
    required this.title,
    required this.hintText,

    required this.controller,
    this.validator,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title),
        TextFormField(
          controller: widget.controller,
          validator:
              widget.validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es requerido';
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
