import 'package:flutter/material.dart';

class ExportButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;

  const ExportButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.download, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );

    if (width != null) {
      return SizedBox(
        width: width,
        height: 38,
        child: button,
      );
    }

    return SizedBox(
      height: 38,
      child: button,
    );
  }
}
