
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapServices {

  

  // Servicio encargado de consumir la API REST de Direcciones
  static Future<List<Position>> fetchRoutePoints({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
  }) async {
    // Obtenemos el token directamente configurado en el SDK para no duplicar llaves
    final token = await MapboxOptions.getAccessToken();
    
    final url = 'https://api.mapbox.com/directions/v5/mapbox/walking/'
        '$originLng,$originLat;$destLng,$destLat'
        '?geometries=geojson&access_token=$token';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Validamos que existan rutas disponibles
      if ((data['routes'] as List).isEmpty) return [];

      // Extraemos la lista de coordenadas geométricas
      final List coords = data['routes'][0]['geometry']['coordinates'];

      // Mapeamos el JSON dinámico a objetos del tipo Position compatibles con Mapbox SDK
      return coords.map((c) => Position(c[0] as double, c[1] as double)).toList();
    } else {
      throw Exception("Fallo la respuesta del servicio de direcciones");
    }
  }
}
