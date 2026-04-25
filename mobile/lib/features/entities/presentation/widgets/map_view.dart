import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(1.2136, -77.2811), // Medellín
        initialZoom: 14.5,
        minZoom: 14,
        maxZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=sCCRiCEG8SLjrAKmpanU',
        ),
      ],
    );
  }
}