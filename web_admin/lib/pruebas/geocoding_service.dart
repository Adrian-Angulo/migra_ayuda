// lib/data/datasources/geocoding_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  /// Convierte una dirección de texto en coordenadas.
  /// Retorna null si no encuentra resultados.
  Future<LatLng?> getCoordinates(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$encoded&format=json&limit=1',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'MigraAyuda/1.0', // Nominatim requiere esto
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return LatLng(
          double.parse(data[0]['lat']),
          double.parse(data[0]['lon']),
        );
      }
    }
    return null;
  }
}
