import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/config/load_token.dart';
import 'package:migra_ayuda/core/utils/helpers/address_normalizer.dart';
import 'package:migra_ayuda/features/map/domain/entities/geocoding_result.dart';

class MapboxDatasource {
  static const Duration _timeout = Duration(seconds: 8);
  
  static const String _pastoBbox = '-77.34,1.15,-77.22,1.27';
  static const String _pastoProximity = '-77.2811,1.2136';

  final http.Client _client;

  MapboxDatasource({http.Client? client})
      : _client = client ?? http.Client();

  Future<GeocodingResult?> getCoordinates(String address) async {
    try {
      final token = await LoadEnv.getMapboxToken();
      if (token.isEmpty) {
        return null;
      }

      final normalizedAddress = AddressNormalizer.normalize(address);
      final encoded = Uri.encodeComponent(normalizedAddress);

      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$encoded.json'
        '?access_token=$token'
        '&country=co'
        '&proximity=$_pastoProximity'
        '&bbox=$_pastoBbox'
        '&types=address,poi,neighborhood,locality'
        '&language=es'
        '&limit=1',
      );

      final response = await _client.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>?;

        if (features != null && features.isNotEmpty) {
          final first = features.first as Map<String, dynamic>;
          final center = first['center'] as List<dynamic>?;
          final placeName = (first['place_name'] as String?) ?? address;

          if (center != null && center.length >= 2) {
            final lng = (center[0] as num).toDouble();
            final lat = (center[1] as num).toDouble();
            return GeocodingResult(
              point: LatLng(lat, lng),
              placeName: placeName,
            );
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Position>?> getWalkingDirections({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
  }) async {
    final token = await LoadEnv.getMapboxToken();
    if (token.isEmpty) {
      return null;
    }

    final url =
        'https://api.mapbox.com/directions/v5/mapbox/walking/$originLng,$originLat;$destLng,$destLat'
        '?geometries=geojson&access_token=$token';

    final response = await _client.get(Uri.parse(url)).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final geometry = routes[0]['geometry'] as Map<String, dynamic>?;
      final coords = geometry?['coordinates'] as List<dynamic>?;
      if (coords == null || coords.isEmpty) return null;

      final positions = coords
          .map<Position>((c) => Position(
                (c[0] as num).toDouble(),
                (c[1] as num).toDouble(),
              ))
          .toList();

      return positions.isNotEmpty ? positions : null;
    }

    return null;
  }
}
