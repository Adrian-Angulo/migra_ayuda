import 'package:flutter/material.dart';

/// Botón reutilizable con icono, texto y acción.
/// Soporta variantes: primario, secundario, peligro, advertencia, texto plano y texto negro.
enum IconTextButtonVariant {
  primary,
  secondary,
  danger,
  warning,
  text,
  textBlack
}

class ButtonWebWidget extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onPressed;
  final IconTextButtonVariant variant;
  final bool iconLeading;
  final double? width;

  const ButtonWebWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.variant = IconTextButtonVariant.primary,
    this.iconLeading = true,
    this.width,
  });

  /// Variante de color verde primario.
  const ButtonWebWidget.primary({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconLeading = true,
    this.width,
  }) : variant = IconTextButtonVariant.primary;

  /// Variante de contorno secundario.
  const ButtonWebWidget.secondary({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconLeading = true,
    this.width,
  }) : variant = IconTextButtonVariant.secondary;

  /// Variante de peligro (rojo) para acciones destructivas.
  const ButtonWebWidget.danger({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconLeading = true,
    this.width,
  }) : variant = IconTextButtonVariant.danger;

  /// Variante de advertencia (amarillo) para acciones de precaución.
  const ButtonWebWidget.warning({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconLeading = true,
    this.width,
  }) : variant = IconTextButtonVariant.warning;

  /// Variante de texto plano sin fondo.
  const ButtonWebWidget.text({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconLeading = true,
    this.width,
  }) : variant = IconTextButtonVariant.text;

  /// Variante de texto negro sin icono ni fondo.
  const ButtonWebWidget.textBlack({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
  })  : variant = IconTextButtonVariant.textBlack,
        icon = null,
        iconLeading = true;

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, borderColor) = switch (variant) {
      IconTextButtonVariant.primary => (
          const Color(0xFF059669),
          Colors.white,
          Colors.transparent,
        ),
      IconTextButtonVariant.secondary => (
          Colors.white,
          const Color(0xFF1B4332),
          const Color(0xFF2D6A4F),
        ),
      IconTextButtonVariant.danger => (
          const Color(0xFFEF4444),
          Colors.white,
          Colors.transparent,
        ),
      IconTextButtonVariant.warning => (
          const Color(0xFFF59E0B),
          Colors.white,
          Colors.transparent,
        ),
      IconTextButtonVariant.text => (
          Colors.transparent,
          const Color(0xFF059669),
          Colors.transparent,
        ),
      IconTextButtonVariant.textBlack => (
          Colors.transparent,
          Colors.black,
          Colors.transparent,
        ),
    };

    final Widget content;

    if (variant == IconTextButtonVariant.textBlack || icon == null) {
      content = Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: iconLeading
            ? [
                Icon(icon, size: 18, color: fgColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, size: 18, color: fgColor),
              ],
      );
    }

    return SizedBox(
      width: width,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: borderColor),
          ),
        ),
        child: content,
      ),
    );
  }
}
