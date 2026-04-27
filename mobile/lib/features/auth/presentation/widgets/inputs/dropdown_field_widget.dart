import 'package:flutter/material.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class DropdownFieldWidget extends StatelessWidget {
  final String title;
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  const DropdownFieldWidget({
    super.key,
    required this.title,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint = "",
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.errorSelectOption;
            }
            return null;
          },
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          hint: Text(hint.isEmpty ? l10n.chooseAnOption : hint),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
