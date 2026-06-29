import 'package:flutter/material.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title),
        const SizedBox(height: 5),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return l10n.errorPasswordRequired;
                }
                if (value.length < 8) {
                  return l10n.errorPasswordMinLength2;
                }
                return null;
              },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: l10n.passwordHint,
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showEye
                  ? IconButton(
                      key: const ValueKey(1),
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
                  : const SizedBox.shrink(key: ValueKey(2)),
            ),
          ),
        ),
      ],
    );
  }
}
