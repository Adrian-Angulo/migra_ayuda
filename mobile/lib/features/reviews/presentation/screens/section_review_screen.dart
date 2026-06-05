import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/place_add_review.dart';

import '../widgets/review_item.dart';

class SectionReviews extends ConsumerStatefulWidget {
  const SectionReviews({
    super.key,
    required this.entity,
    required this.user,
  });

  final EntityEntity entity;
  final UserModel? user;

  @override
  ConsumerState<SectionReviews> createState() => _SectionReviewsState();
}

class _SectionReviewsState extends ConsumerState<SectionReviews> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    final asyncReviews = ref.watch(getReviewsByEntity(widget.entity.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*     ElevatedButton(
            onPressed: () async {
              await SembastDatabase.instance.clearAll();
            },
            child: const Text('Limpiar cache')), */
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Comentarios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceAddReview(
                      entity: widget.entity,
                      user: widget.user,
                    ),
                  ),
                );

                /*  // Verifica si el usuario ya tiene una review
                userReviewAsync?.when(
                  data: (existingReview) {
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
                    } else {
                      // Si no tiene review, navega a crear
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceAddReview(
                            entity: entity,
                            user: user,
                          ),
                        ),
                      );
                    }
                  },
                  loading: () {
                    // Mientras carga, muestra indicador
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Cargando...'),
                        backgroundColor: const Color(0xFF5F9EA0),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  error: (_, __) {
                    // Si hay error, permite crear (asume que no existe)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceAddReview(
                          entity: entity,
                          user: user,
                        ),
                      ),
                    );
                  },
                ); */
              },
              child: const Text(
                // Cambia el texto del botón según si tiene review o no
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
        asyncReviews.when(
          data: (reviews) {
            return reviews.isEmpty ? messageEmty() : containerReviews(reviews);
          },
          error: (error, stackTrace) {
            print("error al llamar reviews: $error");
            return messageError();
          },
          loading: () {
            return const Center(
              child: Text("Cargando..."),
            );
          },
        )
      ],
    );
  }

  ListView containerReviews(reviews) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: Color.fromARGB(255, 212, 212, 212),
      ),
      itemBuilder: (_, i) => ReviewItem(
        review: reviews[i],
        entity: widget.entity,
        user: widget.user!,
      ),
    );
  }

  Center messageError() {
    return Center(
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
    );
  }

  Center messageEmty() {
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
}
