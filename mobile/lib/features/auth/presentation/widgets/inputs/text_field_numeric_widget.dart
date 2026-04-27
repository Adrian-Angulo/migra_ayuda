import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
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
              return l10n.errorAgeRequired;
            }
            final age = int.tryParse(value);
            if (age == null || age < 18 || age > 100) {
              return l10n.errorAgeRange;
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
