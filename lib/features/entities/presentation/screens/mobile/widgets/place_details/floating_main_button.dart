import 'package:flutter/material.dart';

enum FloatingMainButtonVariant { primary, secondary }

class FloatingMainButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final FloatingMainButtonVariant variant;

  const FloatingMainButton({
    super.key,
    required this.text,
    this.icon,
    required this.onTap,
    this.variant = FloatingMainButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == FloatingMainButtonVariant.primary;
    const primaryColor = Color(0xFF00897B);

    return Material(
      color: isPrimary ? primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: isPrimary ? 2 : 0,
      shadowColor: primaryColor.withValues(alpha: 0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon!,
                  color: isPrimary ? Colors.white : const Color(0xFF334155),
                  size: 18,
                ),
              if (icon != null) const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  color: isPrimary ? Colors.white : const Color(0xFF334155),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

