import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/services/google_maps/google_maps_controllers.dart';
import 'package:migra_ayuda/core/widgets/app_bar_widget.dart';
import 'package:migra_ayuda/core/widgets/snackbar_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/floating_main_button.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_header.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_info.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/section_review_screen.dart';

class PlaceDetails extends ConsumerWidget {
  final EntityEntity entity;

  const PlaceDetails({super.key, required this.entity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meanAndLengtReview = ref.watch(meanReviewByEntity(entity.id));
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;

    final asyncStarNavigation = ref.watch(starNavigationNotifierProvider);

    //mostrar mensaje de error de google maps
    ref.listen(
      starNavigationNotifierProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) =>
              SnackbarWidget.error(context, error.toString()),
        );
      },
    );

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
              entity: entity,
            ),
            const SizedBox(height: 16),
            PlaceDetailsInfo(
              entity: entity,
            ),
            const SizedBox(height: 28),

            // Sección de comentarios
            SectionReviews(entity: entity, user: user!),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingMainButton(
          onTap: () async {
            await ref
                .read(starNavigationNotifierProvider.notifier)
                .starNavigation(entity.localitation.latitude,
                    entity.localitation.longitude);
          },
          text: asyncStarNavigation.isLoading ? 'Cargando....' : 'Como llegar',
          icon: Icons.directions,
        ),
      ),
    );
  }
}
