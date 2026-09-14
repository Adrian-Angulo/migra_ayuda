import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BuildTextField extends StatelessWidget {
  const BuildTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines,
    this.onChanged,
    this.validator,
    this.suffixIcon,
    this.maxLength,
    this.onlyNumbers = false,
     this.inputKey,
  });
  final GlobalKey? inputKey;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final int? maxLines;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int? maxLength;
  final bool onlyNumbers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 8),
        TextFormField(
          key: inputKey,
          controller: controller,
          maxLines: maxLines ?? 1,
          onChanged: onChanged,
          maxLength: maxLength,
          inputFormatters: onlyNumbers
              ? <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  if (maxLength != null)
                    LengthLimitingTextInputFormatter(maxLength),
                ]
              : (maxLength != null
                  ? [LengthLimitingTextInputFormatter(maxLength)]
                  : null),
          keyboardType: onlyNumbers ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.grey.shade400, size: 20)
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2D5F4F), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterText: "", // Hides the counter if you wish
          ),
          validator: validator,
        ),
      ],
    );
  }
}
