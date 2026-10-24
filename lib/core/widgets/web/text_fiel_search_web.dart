import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class TextFielSearchWeb extends ConsumerWidget {
  final Function(String)? onChanged;
  final String hintText;
  final double? width;

  const TextFielSearchWeb({
    super.key,
    required this.onChanged,
    required this.hintText,
    this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width ?? 450,
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade500,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: Color(0xFF10B981),
              width: 2,
            ),
          ),
          hoverColor: Colors.transparent,
        ),
      ),
    );
  }
}
