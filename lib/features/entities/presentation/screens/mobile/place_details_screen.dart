import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/services/google_maps/google_maps_controllers.dart';
import 'package:migra_ayuda/core/widgets/mobil/app_bar_widget.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/floating_main_button.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_header.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_info.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/section_review_screen.dart';

class PlaceDetails extends ConsumerWidget {
  final EntityEntity entity;

  const PlaceDetails({super.key, required this.entity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      appBar: AppBarWidget(
        title: "Detalles de la entidad",
        entity: entity,
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
            SectionReviews(entity: entity),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation:
          kIsWeb ? null : FloatingActionButtonLocation.centerFloat,
      floatingActionButton: kIsWeb
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FloatingMainButton(
                onTap: () async {
                  await ref.read(mapProvider.notifier).drawRouteToEntity(entity);
                  if (context.mounted) {
                    final currentMapState = ref.read(mapProvider);
                    if (currentMapState.routeMessage != null) {
                      if (currentMapState.isFallbackRoute) {
                        SnackbarWidget.warning(
                          context,
                          currentMapState.routeMessage!,
                        );
                      } else if (currentMapState.isOfflineRoute) {
                        SnackbarWidget.info(
                          context,
                          currentMapState.routeMessage!,
                        );
                      }
                    }
                    Navigator.pop(context);
                  }
                },
                text: 'Como llegar',
                icon: Icons.directions,
              ),
            ),
    );
  }
}
