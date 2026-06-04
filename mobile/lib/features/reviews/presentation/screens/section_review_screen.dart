import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';

import '../widgets/review_item.dart';

class SectionReviews extends StatelessWidget {
  const SectionReviews({
    super.key,
    required this.entity,
    required this.user,
  });

  final EntityEntity entity;
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    List<ReviewEntity> listReview = [
      ReviewEntity(
          id: '43',
          idMigrante: 'asdfds',
          idEntity: 'fasdfa',
          userName: 'Camilo',
          userCountry: 'Venezuela',
          rating: 3,
          comment:
              'Excelente servicio, me atendieron muy bien y resolvieron todas mis dudas.',
          createdAt: DateTime.now(),
          isSynced: true,
          nameEntity: entity.name),
      ReviewEntity(
          id: '44',
          idMigrante: 'bcdeft',
          idEntity: 'fasdfa',
          userName: 'María',
          userCountry: 'Colombia',
          rating: 5,
          comment:
              'Muy buen lugar, el personal es amable y el proceso fue rápido.',
          createdAt: DateTime.now(),
          isSynced: true,
          nameEntity: entity.name),
      ReviewEntity(
          id: '45',
          idMigrante: 'ghijkl',
          idEntity: 'fasdfa',
          userName: 'José',
          userCountry: 'Perú',
          rating: 4,
          comment:
              'Buena atención en general, aunque el tiempo de espera fue un poco largo.',
          createdAt: DateTime.now(),
          isSynced: true,
          nameEntity: entity.name),
      ReviewEntity(
          id: '46',
          idMigrante: 'mnopqr',
          idEntity: 'fasdfa',
          userName: 'Lucía',
          userCountry: 'Ecuador',
          rating: 2,
          comment:
              'El servicio fue regular, esperaba más información sobre los trámites.',
          createdAt: DateTime.now(),
          isSynced: true,
          nameEntity: entity.name),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        // Vista de comentarios con manejo de estados
        listReview.isEmpty ? messageEmty() : containerReviews(listReview)
        
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
              entity: entity,
              user: user!,
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
