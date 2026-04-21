import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Material App Bar'),
          ),
          body: Stack(
            children: [
              FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(6.2442, -75.5812), // Medellín
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=sCCRiCEG8SLjrAKmpanU',
                    userAgentPackageName: 'com.migraayuda.app',
                  ),
                  
                ],
              )
            ],
          )),
    );
  }
}
