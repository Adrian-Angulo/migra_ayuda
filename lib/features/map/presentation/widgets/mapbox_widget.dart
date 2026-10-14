import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/localitation/location_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/map/presentation/providers/map_display_provider.dart';

class MapboxWidget extends ConsumerStatefulWidget {
  const MapboxWidget({super.key});

  @override
  ConsumerState<MapboxWidget> createState() => _MapboxWidgetState();
}

class _MapboxWidgetState extends ConsumerState<MapboxWidget> {
  late final DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        onMapCreated: (controller) async {
          await ref.read(mapProvider.notifier).setMapController(controller);
          final entities = ref.read(getAllEntitiesProvider).value;
          if (entities != null && entities.isNotEmpty) {
            ref.read(mapProvider.notifier).addMarkers(entities);
          }
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
      
    ]);
  }
}
