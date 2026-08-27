
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:sembast/sembast.dart';

enum RouteSourceType {
  online,
  cached,
  directFallback,
}

class RouteResult {
  final List<Position> points;
  final RouteSourceType sourceType;
  final String message;

  const RouteResult({
    required this.points,
    required this.sourceType,
    required this.message,
  });

  bool get isOffline => sourceType != RouteSourceType.online;
  bool get isFallback => sourceType == RouteSourceType.directFallback;
  bool get isCached => sourceType == RouteSourceType.cached;
}

class MapServices {
  static final _store = stringMapStoreFactory.store('routes_cache');
  static Future<Database> get _db async => await SembastDatabase.instance.database;

  static String _buildKey(String? entityId, double destLng, double destLat) {
    if (entityId != null && entityId.isNotEmpty) {
      return 'route_$entityId';
    }
    return 'route_${destLng.toStringAsFixed(4)}_${destLat.toStringAsFixed(4)}';
  }

  /// Guarda una geometría de ruta en la base de datos local Sembast
  static Future<void> _saveRouteToCache({
    required String key,
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
    required List<dynamic> coordinates,
  }) async {
    try {
      final db = await _db;
      await _store.record(key).put(db, {
        'originLng': originLng,
        'originLat': originLat,
        'destLng': destLng,
        'destLat': destLat,
        'coordinates': coordinates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint("💾 Ruta guardada en caché local: $key");
    } catch (e) {
      debugPrint("⚠️ No se pudo guardar la ruta en caché: $e");
    }
  }

  /// Intenta recuperar una ruta previamente guardada en el almacenamiento local
  static Future<List<Position>?> _getRouteFromCache(String key) async {
    try {
      final db = await _db;
      final record = await _store.record(key).get(db);
      if (record != null && record['coordinates'] is List) {
        final List rawCoords = record['coordinates'] as List;
        return rawCoords
            .map((c) => Position(
                  (c[0] as num).toDouble(),
                  (c[1] as num).toDouble(),
                ))
            .toList();
      }
    } catch (e) {
      debugPrint("⚠️ Error al leer ruta desde la caché local: $e");
    }
    return null;
  }

  /// Obtiene la ruta usando estrategia híbrida:
  /// 1. Mapbox Directions API (Online)
  /// 2. Caché local Sembast (Offline con historial)
  /// 3. Línea geodésica directa (Offline fallback de orientación)
  static Future<RouteResult> fetchRoute({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
    String? entityId,
  }) async {
    final routeKey = _buildKey(entityId, destLng, destLat);

    try {
      // 1. Intento Online vía Mapbox Directions API
      final token = await MapboxOptions.getAccessToken();
      final url = 'https://api.mapbox.com/directions/v5/mapbox/walking/'
          '$originLng,$originLat;$destLng,$destLat'
          '?geometries=geojson&access_token=$token';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if ((data['routes'] as List).isNotEmpty) {
          final List coords = data['routes'][0]['geometry']['coordinates'];

          // Guardar en caché para uso sin conexión futuro
          await _saveRouteToCache(
            key: routeKey,
            originLng: originLng,
            originLat: originLat,
            destLng: destLng,
            destLat: destLat,
            coordinates: coords,
          );

          final positions = coords
              .map((c) => Position(
                    (c[0] as num).toDouble(),
                    (c[1] as num).toDouble(),
                  ))
              .toList();

          return RouteResult(
            points: positions,
            sourceType: RouteSourceType.online,
            message: 'Ruta trazada correctamente',
          );
        }
      }
    } catch (e) {
      debugPrint("⚠️ Falló la obtención de ruta online ($e). Intentando modo offline...");
    }

    // 2. Intento Offline vía Caché Local Sembast
    final cachedPoints = await _getRouteFromCache(routeKey);
    if (cachedPoints != null && cachedPoints.isNotEmpty) {
      debugPrint("✅ Usando ruta en caché local (${cachedPoints.length} puntos)");
      return RouteResult(
        points: cachedPoints,
        sourceType: RouteSourceType.cached,
        message: 'Modo sin conexión: Mostrando ruta guardada',
      );
    }

    // 3. Fallback de Rumbo / Línea Directa hacia la entidad
    debugPrint("🧭 Generando línea directa de orientación (fallback)");
    final directPoints = [
      Position(originLng, originLat),
      Position(destLng, destLat),
    ];

    return RouteResult(
      points: directPoints,
      sourceType: RouteSourceType.directFallback,
      message: 'Modo sin conexión: Línea de orientación directa hacia el destino',
    );
  }

  /// Método retrocompatible
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

