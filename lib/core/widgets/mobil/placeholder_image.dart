import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ Color(0xFF1B4332), Color(0xFF2D6A4F)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, size: 80, color: Colors.white24),
      ),
    );
  }
}
