import 'package:flutter/material.dart';

class TextFieldPaswordWidget extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const TextFieldPaswordWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.validator,
  });

  @override
  State<TextFieldPaswordWidget> createState() => _TextFieldPaswordWidgetState();
}

class _TextFieldPaswordWidgetState extends State<TextFieldPaswordWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: widget.hintText,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
