import 'package:flutter/material.dart';

class TextFieldPaswordWidget extends StatefulWidget {
  final String title;

  final TextEditingController controller;
  final String? Function(String?)? validator;

  const TextFieldPaswordWidget({
    super.key,
    required this.title,

    required this.controller,
    this.validator,
  });

  @override
  State<TextFieldPaswordWidget> createState() => _TextFieldPaswordWidgetState();
}

class _TextFieldPaswordWidgetState extends State<TextFieldPaswordWidget> {
  bool _obscureText = true;
  bool _showEye = false;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      if (widget.controller.text.isNotEmpty && !_showEye) {
        setState(() {
          _showEye = true;
        });
      } else if (widget.controller.text.isEmpty && _showEye) {
        setState(() {
          _showEye = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator:
              widget.validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return "La contraseña es obligatoria";
                }
                if (value.length < 8) {
                  return "Debe tener mínimo 8 caracteres";
                }
                return null;
              },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: "••••••••",
            suffixIcon: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: _showEye
                  ? IconButton(
                      key: ValueKey(1),
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : SizedBox.shrink(key: ValueKey(2)),
            ),
          ),
        ),
      ],
    );
  }
}
