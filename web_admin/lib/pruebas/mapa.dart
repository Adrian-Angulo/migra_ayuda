import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda_administracion/pruebas/geocoding_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Material App Bar')),
        body: const RegisterEntityFrom(),
      ),
    );
  }
}

class RegisterEntityFrom extends StatefulWidget {
  const RegisterEntityFrom({super.key});

  @override
  State<RegisterEntityFrom> createState() => _RegisterEntityFromState();
}

class _RegisterEntityFromState extends State<RegisterEntityFrom> {
  final _addressController = TextEditingController();
  LatLng? _selectedLocation;
  bool _isSearching = false;

  Future<void> _searchAddress() async {
    setState(() => _isSearching = true);

    final coords = await GeocodingService().getCoordinates(
      _addressController.text,
    );

    setState(() {
      _selectedLocation = coords;
      _isSearching = false;
    });

    if (coords == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dirección no encontrada')));
    }
  }

  Future<void> _save() async {
    if (_selectedLocation == null) return;

    // Guarda en Firestore
    await FirebaseFirestore.instance.collection('entities').add({
      'name': 'Nombre de la entidad',
      'address': _addressController.text,
      'latitude': _selectedLocation!.latitude,
      'longitude': _selectedLocation!.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            hintText: 'Ej: Calle 18 #25-40, Pasto',
          ),
        ),
        ElevatedButton(
          onPressed: _isSearching ? null : _searchAddress,
          child: _isSearching
              ? const CircularProgressIndicator()
              : const Text('Buscar dirección'),
        ),

        // Preview en mapa pequeño si ya encontró coords
        (_selectedLocation != null)
            ? Column(
                children: [
                  Text(
                    '📍 ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                  ),
                  SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _selectedLocation!,
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.migraayuda.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation!,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Container(
                height: 200,
                width: double.infinity,
                color: Colors.blue,
                child: const Icon(Icons.map),
              ),
      ],
    );
  }
}
