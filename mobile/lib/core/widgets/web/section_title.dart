import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final double size;

  const SectionTitle(this.text, {this.size = 20, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }
}
