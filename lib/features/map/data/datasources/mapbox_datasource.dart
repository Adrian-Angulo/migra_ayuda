
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/config/load_token.dart';

class MapboxDatasource {
  final http.Client _client;

  MapboxDatasource({http.Client? client})
      : _client = client ?? http.Client();


  Future<LatLng?> getCoordinates(String address) async {
    try {
      final token = await LoadEnv.getMapboxToken();
      if (token.isEmpty) {
        return null;
      }

      final encoded = Uri.encodeComponent(address);
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$encoded.json'
        '?access_token=$token'
        '&country=co'
        '&proximity=-77.2811,1.2136'
        '&types=address,poi,neighborhood,locality'
        '&language=es'
        '&limit=1',
      );

      final response = await _client.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>?;

        if (features != null && features.isNotEmpty) {
          final first = features.first as Map<String, dynamic>;
          final center = first['center'] as List<dynamic>?;

          if (center != null && center.length >= 2) {
           
            final lng = (center[0] as num).toDouble();
            final lat = (center[1] as num).toDouble();
        
            return LatLng(lat, lng);
          }
        }
      } 
      return null;
    } catch (e) {
      return null;
    }
  }
}