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

    ref.listen(
      mapProvider,
      (previous, next) {
        if (next.selectEntity != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.selectEntity!.name),
            ),
          );
        }
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
      DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.15,
        maxChildSize: 0.95,
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
                Column(
                  key: const ValueKey('lista'),
                  children: List.generate(
                    10,
                    (index) => ListTile(
                      leading: const Icon(Icons.history),
                      title: Text('Destino frecuente ${index + 1}'),
                      subtitle: const Text('Calle Falsa 123'),
                      onTap: () {},
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () {
                // Reactivamos el seguimiento automático
                ref.read(mapProvider.notifier).resumeTracking();
                print('presiono el boton');
              },
            ),
          ],
        ),
      ),
    ]);
  }
}
