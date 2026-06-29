import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;

  const RatingWidget({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 25, color: Colors.amber.shade700),
        const SizedBox(width: 4),
        Text(
          '$rating',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
