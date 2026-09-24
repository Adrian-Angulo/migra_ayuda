import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Tipo de origen de la ruta calculada
enum RouteSourceType {
  /// Online por calles (Mapbox Directions API)
  mapboxApi,

  /// Offline / Sin conexión (Línea recta directa de orientación)
  directFallback,
}

/// Resultado de una consulta de ruta
class RouteResult {
  final List<Position> points;
  final RouteSourceType sourceType;
  final String message;

  const RouteResult({
    required this.points,
    required this.sourceType,
    required this.message,
  });

  /// La ruta sigue calles reales
  bool get isStreetRoute => sourceType == RouteSourceType.mapboxApi;

  /// La ruta es de respaldo / sin conexión
  bool get isOffline => sourceType == RouteSourceType.directFallback;

  /// Indica si es ruta de contingencia (línea directa)
  bool get isFallback => sourceType == RouteSourceType.directFallback;

  /// Indica si se obtuvo online
  bool get isOnline => sourceType == RouteSourceType.mapboxApi;
}

/// Contrato abstracto para fuentes de datos remotas de direcciones
abstract class DirectionsRemoteDataSource {
  Future<List<Position>?> getWalkingDirections({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
  });
}

/// Implementación de la fuente de datos remota usando Mapbox Directions API
class MapboxDirectionsRemoteDataSource implements DirectionsRemoteDataSource {
  final http.Client _client;

  MapboxDirectionsRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<Position>?> getWalkingDirections({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
  }) async {
    final token = await MapboxOptions.getAccessToken();
    final url = 'https://api.mapbox.com/directions/v5/mapbox/walking/'
        '$originLng,$originLat;$destLng,$destLat'
        '?geometries=geojson&access_token=$token';

    final response = await _client
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] is List && (data['routes'] as List).isNotEmpty) {
        final List coords = data['routes'][0]['geometry']['coordinates'];
        final positions = coords
            .map((c) => Position(
                  (c[0] as num).toDouble(),
                  (c[1] as num).toDouble(),
                ))
            .toList();
        if (positions.isNotEmpty) {
          return positions;
        }
      }
    }
    return null;
  }
}

/// Contrato abstracto del servicio de cálculo de rutas
abstract class DirectionsService {
  Future<RouteResult> calculateRoute({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
    String? entityId,
  });
}

/// Servicio de rutas que implementa la estrategia de fallback ante fallo de red
class MapServices implements DirectionsService {
  final DirectionsRemoteDataSource _remoteDataSource;

  static final MapServices _defaultInstance = MapServices();

  MapServices({DirectionsRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? MapboxDirectionsRemoteDataSource();

  @override
  Future<RouteResult> calculateRoute({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
    String? entityId,
  }) async {
    try {
      final points = await _remoteDataSource.getWalkingDirections(
        originLng: originLng,
        originLat: originLat,
        destLng: destLng,
        destLat: destLat,
      );

      if (points != null && points.isNotEmpty) {
        debugPrint("🌐 Ruta obtenida de Mapbox API: ${points.length} puntos");
        return RouteResult(
          points: points,
          sourceType: RouteSourceType.mapboxApi,
          message: 'Ruta trazada correctamente',
        );
      }
    } on SocketException catch (e) {
      debugPrint("⚠️ Sin conexión de red (SocketException: $e)");
    } on TimeoutException catch (e) {
      debugPrint("⚠️ Tiempo de espera agotado al consultar Mapbox API ($e)");
    } catch (e) {
      debugPrint("⚠️ Error al obtener ruta de Mapbox API: $e");
    }

    // Fallback directo
    debugPrint("📍 Usando línea directa de orientación al destino");
    return RouteResult(
      points: [
        Position(originLng, originLat),
        Position(destLng, destLat),
      ],
      sourceType: RouteSourceType.directFallback,
      message: 'Sin conexión: Línea directa de orientación al destino',
    );
  }

  /// Método estático para calcular la ruta
  static Future<RouteResult> fetchRoute({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
    String? entityId,
  }) {
    return _defaultInstance.calculateRoute(
      originLng: originLng,
      originLat: originLat,
      destLng: destLng,
      destLat: destLat,
      entityId: entityId,
    );
  }

  /// Método retrocompatible para obtener únicamente los puntos
  static Future<List<Position>> fetchRoutePoints({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
    String? entityId,
  }) async {
    final result = await fetchRoute(
      originLng: originLng,
      originLat: originLat,
      destLng: destLng,
      destLat: destLat,
      entityId: entityId,
    );
    return result.points;
  }
}
