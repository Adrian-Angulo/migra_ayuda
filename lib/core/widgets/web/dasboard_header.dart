import 'package:flutter/material.dart';

class HeaderWeb extends StatelessWidget {
  final String title;
  final String subTitle;
  const HeaderWeb({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(subTitle),
      ],
    );
  }
}
