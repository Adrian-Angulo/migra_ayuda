import 'package:flutter/material.dart';

class FilterButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const FilterButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.filter_list_rounded,
        size: 18,
        color: Colors.grey.shade700,
      ),
      label: Text(
        'Filtro',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
