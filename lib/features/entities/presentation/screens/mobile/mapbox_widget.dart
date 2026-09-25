import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/localitation/location_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/list_Entities_home.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/homeCardWidgets/filter_container.dart';

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

    final screenHeight = MediaQuery.of(context).size.height;

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
      ListEntitesHome(sheetController: _sheetController),
      AnimatedBuilder(
        animation: _sheetController,
        builder: (context, child) {
          final currentSize =
              _sheetController.isAttached ? _sheetController.size : 0.3;

          if (currentSize >= 0.95) {
            return const SizedBox.shrink();
          }

          final opacity =
              ((0.95 - currentSize) / (0.95 - 0.70)).clamp(0.0, 1.0);
          final bottomOffset = (screenHeight * currentSize);

          return Positioned(
            bottom: bottomOffset + 8,
            right: 14,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón estilizado de "Mi ubicación"
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: 'location',
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                child: const Icon(Icons.my_location_rounded, size: 22),
                onPressed: () {
                  ref.read(mapProvider.notifier).resumeTracking();
                },
              ),
            ),
          ],
        ),
      ),
      const FilterContainer(),
    ]);
  }
}
