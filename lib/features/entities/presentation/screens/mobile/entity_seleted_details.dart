
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/services/google_maps/google_maps_controllers.dart';
import 'package:migra_ayuda/features/entities/domain/entities/map_state.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/floating_main_button.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_header.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_info.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/section_review_screen.dart';
import 'package:migra_ayuda/features/userActivity/presentation/providers/activities_providers.dart';
 
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
                FloatingMainButton(
                  onTap: () async {
                    await ref
                        .read(mapProvider.notifier)
                        .drawRouteToEntity(widget.map.selectEntity!);

                    await ref.read(activityProvider.notifier).create(
                          accion: ActivityActions.routeRequested(),
                          metadata: {'service': widget.map.selectEntity!.services[0], 'entidad': widget.map.selectEntity!.name}
                        );
                    widget.controllerD?.animateTo(
                      0.3,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  text: 'Como llegar',
                  icon: Icons.directions,
                  variant: FloatingMainButtonVariant.secondary,
                ),
                FloatingMainButton(
                  onTap: () async {
                    await ref
                        .read(starNavigationNotifierProvider.notifier)
                        .starNavigation(
                            widget.map.selectEntity!.localitation.latitude,
                            widget.map.selectEntity!.localitation.longitude);

                    await ref.read(activityProvider.notifier).create(
                          accion: ActivityActions.navigationMaps(),
                          metadata: {'service': widget.map.selectEntity!.services[0], 'entidad': widget.map.selectEntity!.name}
                        );
                    
                  },
                  text: 'Iniciar viaje',
                  icon: Icons.navigation,
                  variant: FloatingMainButtonVariant.primary,
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
              widget.controllerD?.animateTo(
                0.3,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
      ],
    );
  }
}