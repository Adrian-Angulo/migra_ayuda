import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/services/google_maps/google_maps_controllers.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_widget.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/floating_main_button.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_header.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_info.dart';
import 'package:migra_ayuda/features/map/presentation/providers/map_display_provider.dart';
import 'package:migra_ayuda/features/map/presentation/providers/map_state.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/place_add_review.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/section_review_screen.dart';

class EntitySelectedDetails extends ConsumerStatefulWidget {
  const EntitySelectedDetails({
    super.key,
    required this.map,
    required this.controllerD,
  });

  final MapState map;
  final DraggableScrollableController? controllerD;

  @override
  ConsumerState<EntitySelectedDetails> createState() =>
      _EntitySelectedDetailsState();
}

class _EntitySelectedDetailsState extends ConsumerState<EntitySelectedDetails> {
  @override
  Widget build(BuildContext context) {
    final entity = widget.map.selectEntity!;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlaceDetailsHeader(entity: entity),
            const SizedBox(height: 16),
            PlaceDetailsInfo(entity: entity),
            const SizedBox(height: 16),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: FloatingMainButton(
                    onTap: () async {
                      await ref
                          .read(mapProvider.notifier)
                          .drawRouteToEntity(entity);

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
                      }

                      await ref.read(auditNotifierProvider.notifier).create(
                        accion: ActivityActions.routeRequested(),
                        metadata: {
                          'service': entity.services.isNotEmpty
                              ? entity.services[0]
                              : 'General',
                          'entidad': entity.name,
                        },
                      );

                      if (widget.controllerD != null &&
                          widget.controllerD!.isAttached) {
                        widget.controllerD!.animateTo(
                          0.3,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    text: 'Cómo llegar',
                    icon: Icons.directions,
                    variant: FloatingMainButtonVariant.secondary,
                  ),
                ),
                Expanded(
                  child: FloatingMainButton(
                    onTap: () async {
                      await ref
                          .read(starNavigationNotifierProvider.notifier)
                          .starNavigation(
                            entity.localitation.latitude,
                            entity.localitation.longitude,
                          );

                      await ref.read(auditNotifierProvider.notifier).create(
                        accion: ActivityActions.navigationMaps(),
                        metadata: {
                          'service': entity.services.isNotEmpty
                              ? entity.services[0]
                              : 'General',
                          'entidad': entity.name,
                        },
                      );
                    },
                    text: 'Iniciar viaje',
                    icon: Icons.navigation,
                    variant: FloatingMainButtonVariant.primary,
                  ),
                ),
              ],
            ),
            SectionReviews(entity: entity),
            const SizedBox(height: 16),
          ],
        ),
        CloseButtom(ref: ref, widget: widget),
        Positioned(
            left: 10,
            top: 195,
            child: FloatingMainButton(text: 'Añadir Comentario', onTap: () {
               Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceAddReview(
                        entity: entity,
                        
                      ),
                    ),
                  );
            }))
      ],
    );
  }
}

class CloseButtom extends StatelessWidget {
  const CloseButtom({
    super.key,
    required this.ref,
    required this.widget,
  });

  final WidgetRef ref;
  final EntitySelectedDetails widget;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            ref.read(mapProvider.notifier).clearSelectEntity();
            ref.read(mapProvider.notifier).clearRoute();
            if (widget.controllerD != null && widget.controllerD!.isAttached) {
              widget.controllerD!.animateTo(
                0.3,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          },
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
