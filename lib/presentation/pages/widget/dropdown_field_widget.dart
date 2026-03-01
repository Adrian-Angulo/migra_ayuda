import 'package:flutter/material.dart';

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
    this.hint = "Elige una opción",
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Por favor selecciona una opción";
              }
              return null;
            },
            items: items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            hint: Text(hint),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
