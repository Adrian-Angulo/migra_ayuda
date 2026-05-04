import 'package:dartz/dartz.dart' as entity;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/utils/format/time_formatter.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/edit_review_provider.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/place_edit_review.dart';

class ReviewItem extends ConsumerWidget {
  final ReviewEntity review;
  final UserModel user;
  final EntityEntity entity;

  const ReviewItem(
      {super.key,
      required this.review,
      required this.user,
      required this.entity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userReviewAsync = ref.watch(
        userReviewByEntityProvider((userId: user.id, entityId: entity.id)));

    /// Muestra diálogo de confirmación para eliminar
    Future<void> _showDeleteConfirmation() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar comentario'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este comentario? Esta acción no se puede deshacer.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Elimina la review
        await ref.read(editReviewProvider.notifier).deleteReview(
              reviewId: review.id,
              idMigrante: review.idMigrante,
              idEntity: review.idEntity,
            );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.userCountry,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    TimeFormatter.formatDate(review.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB0B7C3),
                    ),
                  ),
                  if (user.id == review.idMigrante)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          userReviewAsync.whenData(
                            (existingReview) {
                              if (existingReview != null) {
                                // Si ya tiene review, navega a editar
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaceEditReview(
                                      entity: entity,
                                      existingReview: existingReview,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        } else if (value == 'delete') {
                          _showDeleteConfirmation();
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < review.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 18,
                color: i < review.rating
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFD1D5DB),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
