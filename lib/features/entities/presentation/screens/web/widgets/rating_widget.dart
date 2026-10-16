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

    final String displayRating = ratingAsync.when(
      data: (rating) {
        final count = rating['count'];
        final mean = rating['mean'];
        if (count != null && count > 0 && mean != null) {
          return mean.toString();
        }
        if (entity.averageRating > 0) {
          return entity.averageRating.toStringAsFixed(1);
        }
        return '0.0';
      },
      loading: () {
        if (entity.averageRating > 0) {
          return entity.averageRating.toStringAsFixed(1);
        }
        return '---';
      },
      error: (_, __) {
        if (entity.averageRating > 0) {
          return entity.averageRating.toStringAsFixed(1);
        }
        return '0.0';
      },
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: 22,
          color: displayRating == '---' ? Colors.grey : Colors.amber.shade700,
        ),
        const SizedBox(width: 4),
        Text(
          displayRating,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
