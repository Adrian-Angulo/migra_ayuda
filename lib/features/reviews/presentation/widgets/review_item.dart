import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/utils/format/time_formatter.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/place_edit_review.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';

import '../providers/review_providers.dart';

class ReviewItem extends ConsumerWidget {
  final ReviewEntity review;
  final Migrant? user;
  final EntityEntity entity;

  const ReviewItem({
    super.key,
    required this.review,
    this.user,
    required this.entity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> showDeleteConfirmationDialog() async {
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar comentario'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este comentario? Esta acción no se puede deshacer.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            _buildCancelButton(context),
            const SizedBox(width: 8),
            _buildDeleteButton(context, ref),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, showDeleteConfirmationDialog),
          const SizedBox(height: 8),
          _buildRatingStars(review.rating),
          const SizedBox(height: 8),
          _buildComment(review.comment),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF3F4F6),
        foregroundColor: const Color(0xFF6B7280),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () => Navigator.pop(context, false),
      child: const Text('Cancelar'),
    );
  }

  Widget _buildDeleteButton(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final asyncReview = ref.watch(reviewNotifierProvider);
        final isLoading = asyncReview.isLoading;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: const Color(0xFFFFEAEA),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: isLoading
              ? null
              : () async {
                  await ref
                      .read(reviewNotifierProvider.notifier)
                      .deleteReview(review);

                  await Future.delayed(const Duration(milliseconds: 1000));
                  if (context.mounted) {
                    Navigator.pop(context, true);
                    ref.read(reviewNotifierProvider.notifier).resetState();
                  }
                },
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Eliminar'),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() showDeleteConfirmation,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildUserInfoSection(),
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
            if (user?.id == review.idMigrante)
              _buildPopupMenu(context, showDeleteConfirmation),
          ],
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
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
    );
  }

  Widget _buildPopupMenu(
    BuildContext context,
    Future<void> Function() showDeleteConfirmation,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceEditReview(
                  entity: entity,
                  existingReview: review,
                ),
              ),
            );
            break;
          case 'delete':
            showDeleteConfirmation();
            break;
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
              Icon(Icons.delete_outline, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 18,
          color: i < rating ? const Color(0xFFFBBF24) : const Color(0xFFD1D5DB),
        );
      }),
    );
  }

  Widget _buildComment(String comment) {
    return Text(
      comment,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF374151),
        height: 1.5,
      ),
    );
  }
}
