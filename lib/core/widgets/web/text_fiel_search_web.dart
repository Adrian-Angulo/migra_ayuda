import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextFielSearchWeb extends ConsumerWidget {
  final Function(String)? onChanged;
  final String hintText;

  const TextFielSearchWeb(
      {super.key, required this.onChanged, required this.hintText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 450,
      child: TextField(
        onChanged: onChanged,
        /*  onChanged: (value) => ref.read(queryUserProvider.notifier).state =
            value.toLowerCase().trim(), */
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
          suffixIcon: IconButton(
            onPressed: () {
              // Limpiar búsqueda
            },
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: Colors.grey.shade500,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
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
