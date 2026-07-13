import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/widgets/web/zoom_buttom_widget.dart';

/// Mapa estático con marcador de la entidad.
class MapWeb extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapWeb({super.key, required this.latitude, required this.longitude});

  @override
  State<MapWeb> createState() => MapWebState();
}

class MapWebState extends State<MapWeb> {
  final MapController _mapController = MapController();

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(widget.latitude, widget.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 250,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: point,
                initialZoom: 14,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.migraayuda.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      child: const Icon(
                        Icons.location_pin,
                        color: Color(0xFF059669),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                children: [
                  ZoomButtomWidget(
                    tooltip: 'Acercar',
                    icon: Icons.add,
                    onPressed: _zoomIn,
                  ),
                  const SizedBox(height: 4),
                  ZoomButtomWidget(
                    tooltip: 'Alejar',
                    icon: Icons.remove,
                    onPressed: _zoomOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
