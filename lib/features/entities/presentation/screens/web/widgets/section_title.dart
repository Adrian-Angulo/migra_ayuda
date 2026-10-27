import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 500;

    final double iconSize = isCompact ? 18 : 20;
    final double fontSize = isCompact ? 15 : 18;
    final double spacing = isCompact ? 8 : 12;
    final EdgeInsets containerPadding = EdgeInsets.all(isCompact ? 6.0 : 8.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: containerPadding,
          decoration: BoxDecoration(
            color: const Color(0xFF2D5F4F).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: iconSize, color: const Color(0xFF2D5F4F)),
        ),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}
