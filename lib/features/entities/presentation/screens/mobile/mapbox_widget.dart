import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/providers/location_provider.dart';
import 'package:migra_ayuda/core/services/google_maps/google_maps_controllers.dart';
import 'package:migra_ayuda/features/entities/domain/entities/map_state.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/filter_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/homeCardWidgets/entity_card_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/homeCardWidgets/text_result.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/floating_main_button.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_header.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/place_details_info.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/section_review_screen.dart';
import 'package:migra_ayuda/features/userActivity/presentation/providers/activities_providers.dart';

class MapboxWidget extends ConsumerWidget {
  const MapboxWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      liveLocationProvider,
      (previous, next) {
        next.whenOrNull(
          data: (data) {
            ref
                .read(mapProvider.notifier)
                .location(Position(data.longitude, data.latitude));
          },
        );
      },
    );

    ref.listen(
      listaEntidades,
      (previous, next) {
        next.whenData(
          (entities) {
            ref.read(mapProvider.notifier).addMarkers(entities);
          },
        );
      },
    );

    return Stack(children: [
      MapWidget(
        onMapCreated: (controller) {
          ref.read(mapProvider.notifier).setMapController(controller);
        },
        styleUri: "mapbox://styles/migrayuda/cmqcwpgo0009g01s34h3ifybo",
        onScrollListener: (context) {
          ref.read(mapProvider.notifier).pauseTracking();
        },
        onZoomListener: (context) {
          ref.read(mapProvider.notifier).pauseTracking();
        },
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(-77.2811, 1.2136)),
          zoom: 12.5,
        ),
      ),
      const ListEntitesHome(),
      Positioned(
        bottom: 30,
        right: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Botón de "Mi ubicación"
            FloatingActionButton(
              heroTag: 'location',
              backgroundColor: const Color(0xFF6FA3A1),
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () {
                // Reactivamos el seguimiento automático
                ref.read(mapProvider.notifier).resumeTracking();
              },
            ),
          ],
        ),
      ),
    ]);
  }
}

class ListEntitesHome extends ConsumerStatefulWidget {
  const ListEntitesHome({
    super.key,
  });

  @override
  ConsumerState<ListEntitesHome> createState() => _ListEntitesHomeState();
}

class _ListEntitesHomeState extends ConsumerState<ListEntitesHome> {
  DraggableScrollableController? controllerD = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    String selectedFiltro = ref.watch(seletedFilterProvider);
    final lista = ref.watch(listaEntidades);
    final map = ref.watch(mapProvider);

    return DraggableScrollableSheet(
      controller: controllerD,
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, spreadRadius: 1),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (map.selectEntity == null)
                  lista.when(
                      data: (data) {
                        if (data.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off,
                                    size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  'No se encontraron entidades proveedoras de servicio $selectedFiltro',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          spacing: 5,
                          key: const ValueKey('lista'),
                          children: [
                            const TextResult(),
                            ...List.generate(
                              data.length,
                              (index) => EntityCardWidget(entity: data[index]),
                            ),
                          ],
                        );
                      },
                      error: (error, stackTrace) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'Ocurrió un error al cargar los servicios',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ],
                            ),
                          ),
                      loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ))
                else
                  EntitySeletedDetails(
                      map: map, controllerD: controllerD),
              ],
            ));
      },
    );
  }
}

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
                          metadata: {'service': widget.map.selectEntity!.services[0]}
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
