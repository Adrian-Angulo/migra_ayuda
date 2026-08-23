
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final AsyncValue<int> value;
  final IconData icon;

  const StatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  Color _getColorByTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('usuarios')) {
      return Colors.blue;
    } else if (lowerTitle.contains('entidades')) {
      return Colors.green;
    } else if (lowerTitle.contains('reseñas')) {
      return const Color(0xFF9333EA);
    } else if (lowerTitle.contains('Inicios de sesion')) {
      return const Color(0xFFEA580C);
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getColorByTitle(title);
    return FadeInRight(
      
      child: Container(
        height: 110,
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: ContainerDecorationBorder.decorationBox(),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: cardColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF464555),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  value.when(
                    data: (data) => StaticTitle(value: data.toString()),
                    error: (error, stackTrace) =>
                        StaticTitle(value: error.toString()),
                    loading: () => const SizedBox(
                      width: 30,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StaticTitle extends StatelessWidget {
  const StaticTitle({
    super.key,
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
