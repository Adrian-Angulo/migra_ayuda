import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 2,
      indent: 76,
      endIndent: 20,
      color: Colors.grey,
    );
  }
}
