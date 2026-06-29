import 'package:flutter/material.dart';

class ExportButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const ExportButtonWidget({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 48,
      child: ElevatedButton.icon(
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
