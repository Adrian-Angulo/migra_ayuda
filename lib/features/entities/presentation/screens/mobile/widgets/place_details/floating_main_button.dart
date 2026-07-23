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
    return Expanded(
      child: Material(
        color: isPrimary ? const Color(0xFF5F9EA0) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: isPrimary
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF5F9EA0),
                      width: 1.5,
                    ),
                  ),
            child: Row(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(
                    icon!,
                    color: isPrimary ? Colors.white : const Color(0xFF5F9EA0),
                    size: 17,
                  ),
                Text(
                  text,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : const Color(0xFF5F9EA0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
