import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Resumen general',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}