import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/localitation/location_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/list_Entities_home.dart';

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
      ListEntitesHome(sheetController: _sheetController),
      AnimatedBuilder(
        animation: _sheetController,
        builder: (context, child) {
          final currentSize =
              _sheetController.isAttached ? _sheetController.size : 0.3;

          // Si el sheet cubre el 95% o más de la pantalla, desaparece por completo
          if (currentSize >= 0.95) {
            return const SizedBox.shrink();
          }

          // Desvanecimiento gradual entre 70% y 95% de altura
          final opacity =
              ((0.95 - currentSize) / (0.95 - 0.70)).clamp(0.0, 1.0);
          final bottomOffset = (screenHeight * currentSize);

          return Positioned(
            bottom: bottomOffset,
            right: 10,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
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
