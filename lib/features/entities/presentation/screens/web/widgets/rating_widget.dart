import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';

class RatingWidget extends ConsumerWidget {
  final EntityEntity entity;

  const RatingWidget({super.key, required this.entity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingAsync = ref.watch(meanReviewByEntity(entity.id));

    return ratingAsync.when(
      loading: () => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 25, color: Colors.amber),
          SizedBox(width: 4),
          Text('---',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
      error: (_, __) => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 25, color: Colors.grey),
          SizedBox(width: 4),
          Text('N/A',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
      data: (rating) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 25, color: Colors.amber.shade700),
          const SizedBox(width: 4),
          Text(
            '${rating['mean']}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
