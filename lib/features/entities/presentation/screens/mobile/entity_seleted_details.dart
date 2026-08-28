import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/services/google_maps/google_maps_controllers.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_widget.dart';
import 'package:migra_ayuda/features/entities/domain/entities/map_state.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/floating_main_button.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_header.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_info.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/section_review_screen.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class EntitySeletedDetails extends ConsumerStatefulWidget {
  const EntitySeletedDetails({
    super.key,
    required this.map,
    required this.controllerD,
  });

  final MapState map;
  final DraggableScrollableController? controllerD;

  @override
  ConsumerState<EntitySeletedDetails> createState() =>
      _EntitySeletedDetailsState();
}

class _EntitySeletedDetailsState extends ConsumerState<EntitySeletedDetails> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlaceDetailsHeader(
              entity: widget.map.selectEntity!,
            ),
            const SizedBox(height: 16),
            PlaceDetailsInfo(
              entity: widget.map.selectEntity!,
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: FloatingMainButton(
                    onTap: () async {
                      await ref
                          .read(mapProvider.notifier)
                          .drawRouteToEntity(widget.map.selectEntity!);

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
                            'service': widget.map.selectEntity!.services[0],
                            'entidad': widget.map.selectEntity!.name
                          });

                      if (widget.controllerD != null &&
                          widget.controllerD!.isAttached) {
                        widget.controllerD!.animateTo(
                          0.3,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                      
                    },
                    text: l10n.howToGetThere,
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
                              widget.map.selectEntity!.localitation.latitude,
                              widget.map.selectEntity!.localitation.longitude);

                      await ref.read(auditNotifierProvider.notifier).create(
                          accion: ActivityActions.navigationMaps(),
                          metadata: {
                            'service': widget.map.selectEntity!.services[0],
                            'entidad': widget.map.selectEntity!.name
                          });
                    },
                    text: l10n.startTrip,
                    icon: Icons.navigation,
                    variant: FloatingMainButtonVariant.primary,
                  ),
                ),
              ],
            ),
            // Sección de comentarios
            SectionReviews(entity: widget.map.selectEntity!),
            const SizedBox(height: 16),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton.filled(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              //limpiar entidad seleccionada
              ref.read(mapProvider.notifier).clearSelectEntity();
              // limpiamos la ruta trazada
              ref.read(mapProvider.notifier).clearRoute();
              //volver a la altura iniciar
              if (widget.controllerD != null &&
                  widget.controllerD!.isAttached) {
                widget.controllerD!.animateTo(
                  0.3,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
