import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/providers/location_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';

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
      Positioned(
        bottom: 30,
        right: 20,
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.my_location, color: Colors.white),
          onPressed: () {
            // Reactivamos el seguimiento automático
            ref.read(mapProvider.notifier).resumeTracking();
          },
        ),
      ),
    ]);
  }
}
