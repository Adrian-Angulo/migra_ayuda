import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_widget.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/place_add_review.dart';
import '../widgets/review_item.dart';

class SectionReviews extends ConsumerStatefulWidget {
  const SectionReviews({
    super.key,
    required this.entity,
  });

  final EntityEntity entity;

  @override
  ConsumerState<SectionReviews> createState() => _SectionReviewsState();
}

class _SectionReviewsState extends ConsumerState<SectionReviews> {
  @override
  Widget build(BuildContext context) {
    final asyncReviews = ref.watch(getReviewsByEntity(widget.entity.id));
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;

    final int countReviews = asyncReviews.value?.length ?? 0;

    //Mostrar mensaje de eliminacion;
    ref.listen(
      reviewNotifierProvider,
      (previous, next) {
        if (previous?.isLoading == true && !next.isLoading) {
          if (next.value == ReviewState.deleting) {
            SnackbarWidget.success(context, "Comentario eliminado con éxito");
          } else if (next.hasError) {
            SnackbarWidget.error(context, next.error.toString());
          }
        }
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$countReviews ${countReviews == 1 ? "Reseña" : "Reseñas"}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            if (!kIsWeb)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceAddReview(
                        entity: widget.entity,
                        user: user,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Añadir comentario',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
              )
          ],
        ),
        asyncReviews.when(
          data: (reviews) {
            return reviews.isEmpty
                ? messageEmty()
                : containerReviews(reviews, user!);
          },
          error: (error, stackTrace) {
            debugPrint("error al llamar reviews: $error");
            return messageError();
          },
          loading: () {
            return const SizedBox(
                height: 300, child: Center(child: Text("Cargando...")));
          },
        ),
        const SizedBox(
          height: 60,
        )
      ],
    );
  }

  ListView containerReviews(reviews, UserModel user) {
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
        user: user,
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
              "Sin reseñas aún",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
