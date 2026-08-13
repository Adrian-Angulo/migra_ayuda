import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/localitation/location_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/list_Entities_home.dart';

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
      getAllEntitiesProvider,
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
        bottom: 80,
        right: 10,
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
