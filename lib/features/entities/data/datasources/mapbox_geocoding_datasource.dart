import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/config/load_token.dart';
import 'package:migra_ayuda/features/entities/data/datasources/geocoding_remote_datasource.dart';

class MapboxGeocodingDatasource implements IGeocodingRemoteDataSource {
  final http.Client _client;

  MapboxGeocodingDatasource({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<LatLng?> getCoordinates(String address) async {
    try {
      final token = await Loadtoken.getMapboxToken();
      if (token.isEmpty) {
        debugPrint('⚠️ Mapbox token no configurado');
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
            // Mapbox retorna [longitud, latitud]
            final lng = (center[0] as num).toDouble();
            final lat = (center[1] as num).toDouble();
            debugPrint(
                '📍 Mapbox Geocoding encontró: $lat, $lng para "$address"');
            return LatLng(lat, lng);
          }
        }
      } else {
        debugPrint('⚠️ Mapbox Geocoding status: ${response.statusCode}');
      }
      return null;
    } catch (e, s) {
      debugPrint('⚠️ Error en MapboxGeocodingDatasource: $e');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }
}
