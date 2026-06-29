
import 'package:flutter/material.dart';

/// Tarjeta de comentario de usuario.
class CommentCardWidget extends StatelessWidget {
  final String initials;
  final String name;
  final String timeAgo;
  final int rating;
  final String comment;
  final Color avatarColor;
  final Color initialsColor;

  const CommentCardWidget({super.key, 
    required this.initials,
    required this.name,
    required this.timeAgo,
    required this.rating,
    required this.comment,
    required this.avatarColor,
    required this.initialsColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(
              initials: initials, color: avatarColor, textColor: initialsColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _StarRow(rating: rating),
                const SizedBox(height: 8),
                Text(
                  comment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  final Color textColor;

  const _Avatar({
    required this.initials,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}


class _StarRow extends StatelessWidget {
  final int rating;

  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 15,
          color: i < rating ? const Color(0xFFFBBF24) : const Color(0xFFE5E7EB),
        ),
      ),
    );
  }
}
