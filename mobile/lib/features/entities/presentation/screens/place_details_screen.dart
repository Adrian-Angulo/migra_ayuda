import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/widgets/app_bar_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/floating_main_button.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/place_details/place_details_header.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/place_details/place_details_info.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/place_add_review.dart';
import 'package:migra_ayuda/features/reviews/presentation/widgets/review_item.dart';

class PlaceDetails extends ConsumerWidget {
  final EntityEntity entity;

  const PlaceDetails({super.key, required this.entity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;

    // Obtiene las reviews de la entidad
    final reviewsAsync = ref.watch(reviewsByEntityStreamProvider(entity.id));

    // Obtiene el rating promedio
    final averageRating = ref.watch(averageRatingProvider(entity.id));

    // Obtiene el conteo de reviews
    final reviewCount = ref.watch(reviewCountProvider(entity.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AppBarWidget(
        title: "Detalles de la entidad",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlaceDetailsHeader(
              imageUrl: entity.imageUrl,
              name: entity.name,
              rating: averageRating,
              reviewCount: reviewCount,
              service: entity.services.isNotEmpty ? entity.services.first : '',
            ),
            const SizedBox(height: 16),
            PlaceDetailsInfo(
              entity: entity,
            ),
            const SizedBox(height: 28),

            // Sección de comentarios
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$reviewCount ${reviewCount == 1 ? 'Comentario' : 'Comentarios'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceAddReview(
                            entity: entity,
                            user: user,
                          ),
                        ),
                      ),
                      child: const Text(
                        "Añadir comentario",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),

                // Vista de comentarios con manejo de estados
                reviewsAsync.when(
                  data: (reviews) {
                    if (reviews.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Aún no hay comentarios",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Sé el primero en dejar una reseña",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Color.fromARGB(255, 212, 212, 212),
                      ),
                      itemBuilder: (_, i) => ReviewItem(review: reviews[i]),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(
                        color: Color(0xFF5F9EA0),
                      ),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Error al cargar comentarios",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.red[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Intenta de nuevo más tarde",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingMainButton(
          onTap: () {},
          text: 'Como llegar',
          icon: Icons.directions,
        ),
      ),
    );
  }
}
