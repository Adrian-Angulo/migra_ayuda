
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:migra_ayuda/core/localitation/graph/osm_graph_service.dart';
import 'package:migra_ayuda/core/localitation/graph/route_calculator.dart';
import 'package:sembast/sembast.dart';

enum RouteSourceType {
  /// Ruta calculada localmente con el grafo OSM y algoritmo A*
  localAstar,
  /// Ruta obtenida de la API de Mapbox Directions (online, fallback)
  mapboxApi,
  /// Ruta cargada desde el historial local en Sembast
  cached,
  /// Línea recta directa de orientación (último recurso)
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

  /// La ruta está disponible y sigue calles reales
  bool get isStreetRoute =>
      sourceType == RouteSourceType.localAstar ||
      sourceType == RouteSourceType.mapboxApi;

  /// La ruta es de calidad reducida (caché viejo o línea directa)
  bool get isOffline => sourceType == RouteSourceType.cached ||
      sourceType == RouteSourceType.directFallback;

  bool get isFallback => sourceType == RouteSourceType.directFallback;
  bool get isCached => sourceType == RouteSourceType.cached;

  // Retrocompatibilidad con código existente
  bool get isOnline => !isOffline;
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

  /// Obtiene la ruta usando estrategia híbrida de 4 niveles:
  ///
  /// 1. 🧭 Motor A* local sobre grafo OSM (funciona 100% offline)
  /// 2. 🌐 API de Mapbox Directions (cuando no hay grafo OSM local)
  /// 3. 💾 Caché Sembast (ruta guardada previamente)
  /// 4. 📍 Línea directa (último recurso de orientación)
  static Future<RouteResult> fetchRoute({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
    String? entityId,
  }) async {
    final routeKey = _buildKey(entityId, destLng, destLat);

    // ──────────────────────────────────────────────────────────────
    // NIVEL 1: Motor A* local con grafo OSM (offline first)
    // ──────────────────────────────────────────────────────────────
    try {
      final graph = await OsmGraphService.getGraph();
      if (graph != null && !graph.isEmpty) {
        final calculator = RouteCalculator(graph);
        final route = calculator.calculate(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
        );

        if (route != null && route.length >= 2) {
          debugPrint("🧭 Ruta calculada localmente (A*): ${route.length} puntos");

          // Guardar en caché Sembast para historial
          await _saveRouteToCache(
            key: routeKey,
            originLng: originLng,
            originLat: originLat,
            destLng: destLng,
            destLat: destLat,
            coordinates: route.map((p) => [p.lng, p.lat]).toList(),
          );

          return RouteResult(
            points: route,
            sourceType: RouteSourceType.localAstar,
            message: 'Ruta calculada localmente',
          );
        }
      }
    } catch (e) {
      debugPrint("⚠️ Motor A* no disponible: $e");
    }

    // ──────────────────────────────────────────────────────────────
    // NIVEL 2: API de Mapbox Directions (fallback online)
    // ──────────────────────────────────────────────────────────────
    try {
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

          debugPrint("🌐 Ruta obtenida de Mapbox API: ${positions.length} puntos");
          return RouteResult(
            points: positions,
            sourceType: RouteSourceType.mapboxApi,
            message: 'Ruta trazada correctamente',
          );
        }
      }
    } catch (e) {
      debugPrint("⚠️ Mapbox API no disponible ($e). Intentando caché...");
    }

    // ──────────────────────────────────────────────────────────────
    // NIVEL 3: Caché Sembast (ruta guardada previamente)
    // ──────────────────────────────────────────────────────────────
    final cachedPoints = await _getRouteFromCache(routeKey);
    if (cachedPoints != null && cachedPoints.isNotEmpty) {
      debugPrint("💾 Usando ruta en caché local (${cachedPoints.length} puntos)");
      return RouteResult(
        points: cachedPoints,
        sourceType: RouteSourceType.cached,
        message: 'Sin conexión: Mostrando ruta guardada',
      );
    }

    // ──────────────────────────────────────────────────────────────
    // NIVEL 4: Línea directa de orientación (último recurso)
    // ──────────────────────────────────────────────────────────────
    debugPrint("📍 Generando línea directa de orientación (fallback)");
    return RouteResult(
      points: [
        Position(originLng, originLat),
        Position(destLng, destLat),
      ],
      sourceType: RouteSourceType.directFallback,
      message: 'Sin conexión: Línea de orientación directa al destino',
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



