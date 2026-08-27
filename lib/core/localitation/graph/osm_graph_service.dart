import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:migra_ayuda/core/config/sembast_database.dart';
import 'package:sembast/sembast.dart';

import 'road_graph.dart';

/// Servicio que descarga la red vial de OpenStreetMap via Overpass API
/// y la persiste en la base de datos local Sembast para uso offline.
///
/// Patron: mismo que EntityLocalDataSource / ReviewLocalDataSource del proyecto.
class OsmGraphService {
  static final _store = stringMapStoreFactory.store('osm_graph');
  static const _graphKey = 'pasto_graph_v1';

  // Bounding box Pasto: minLat=1.14, minLng=-77.34, maxLat=1.27, maxLng=-77.22

  /// Cache en memoria del grafo para no re-leer Sembast en cada calculo
  static RoadGraph? _memoryCache;

  static Future<Database> get _db async => await SembastDatabase.instance.database;

  /// Retorna true si ya existe un grafo guardado en Sembast
  static Future<bool> hasGraph() async {
    try {
      final db = await _db;
      final record = await _store.record(_graphKey).get(db);
      return record != null;
    } catch (e) {
      return false;
    }
  }

  /// Descarga el grafo vial de Pasto desde Overpass API y lo guarda en Sembast.
  /// Retorna true si la descarga y el guardado fueron exitosos.
  ///
  /// La consulta obtiene todas las vias peatonales/vehiculares del bbox de Pasto.
  static Future<bool> downloadAndSave() async {
    try {
      debugPrint('🗺️ Descargando grafo vial OSM para Pasto...');

      // Consulta Overpass: vias transitables para peatones en el bbox de Pasto
      // Bbox: minLat=1.14, minLng=-77.34, maxLat=1.27, maxLng=-77.22
      const query =
          '[out:json][timeout:90];'
          '(way["highway"~"^(primary|secondary|tertiary|unclassified|residential|'
          r'pedestrian|footway|path|steps|living_street|service)$"]'
          '(1.1400,-77.3400,1.2700,-77.2200);'
          ');(._;>;);out;';

      final response = await http
          .post(
            Uri.parse('https://overpass-api.de/api/interpreter'),
            body: {'data': query},
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode != 200) {
        debugPrint('❌ Overpass API error: ');
        return false;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final elements = data['elements'] as List<dynamic>;

      // 1. Parsear todos los nodos OSM
      final nodeMap = <String, RoadNode>{};
      for (final el in elements) {
        if (el['type'] == 'node') {
          final id = el['id'].toString();
          nodeMap[id] = RoadNode(
            id: id,
            lat: (el['lat'] as num).toDouble(),
            lng: (el['lon'] as num).toDouble(),
          );
        }
      }

      // 2. Construir lista de adyacencia desde las vias OSM
      final adjacency = <String, List<RoadEdge>>{};
      for (final el in elements) {
        if (el['type'] != 'way') continue;

        final tags = el['tags'] as Map<String, dynamic>? ?? {};
        final nodeIds =
            (el['nodes'] as List<dynamic>).map((n) => n.toString()).toList();
        final isOneway = tags['oneway'] == 'yes';
        // Las vias peatonales ignoran la restriccion de sentido unico
        final isPedestrian = ['footway', 'pedestrian', 'path', 'steps']
            .contains(tags['highway']);

        for (int i = 0; i < nodeIds.length - 1; i++) {
          final fromId = nodeIds[i];
          final toId = nodeIds[i + 1];

          if (!nodeMap.containsKey(fromId) || !nodeMap.containsKey(toId)) {
            continue;
          }

          final from = nodeMap[fromId]!;
          final to = nodeMap[toId]!;
          final dist = _haversine(from.lat, from.lng, to.lat, to.lng);

          // Arista hacia adelante
          adjacency.putIfAbsent(fromId, () => []).add(RoadEdge(to: toId, weight: dist));

          // Arista inversa (bidireccional salvo sentido unico no peatonal)
          if (!isOneway || isPedestrian) {
            adjacency.putIfAbsent(toId, () => []).add(RoadEdge(to: fromId, weight: dist));
          }
        }
      }

      final graph = RoadGraph(nodes: nodeMap, adjacency: adjacency);
      final totalEdges = adjacency.values.fold(0, (s, e) => s + e.length);
      debugPrint('✅ Grafo construido:  nodos,  aristas');

      // 3. Serializar y guardar en Sembast
      final compact = graph.toCompactJson();
      final db = await _db;
      await _store.record(_graphKey).put(db, {
        'data': json.encode(compact),
        'updatedAt': DateTime.now().toIso8601String(),
        'nodeCount': nodeMap.length,
        'edgeCount': totalEdges,
      });

      // Actualizar cache en memoria
      _memoryCache = graph;

      debugPrint('💾 Grafo vial guardado en base de datos local');
      return true;
    } catch (e) {
      debugPrint('❌ Error descargando grafo OSM: ');
      return false;
    }
  }

  /// Carga el grafo desde Sembast (con cache en memoria para rendimiento)
  static Future<RoadGraph?> getGraph() async {
    // Retornar cache en memoria si ya esta cargado
    if (_memoryCache != null && !_memoryCache!.isEmpty) {
      return _memoryCache;
    }

    try {
      final db = await _db;
      final record = await _store.record(_graphKey).get(db);
      if (record == null) return null;

      final jsonStr = record['data'] as String;
      final compact = json.decode(jsonStr) as Map<String, dynamic>;
      _memoryCache = RoadGraph.fromCompactJson(compact);

      debugPrint(
          '✅ Grafo cargado:  nodos');
      return _memoryCache;
    } catch (e) {
      debugPrint('❌ Error cargando grafo OSM: ');
      return null;
    }
  }

  /// Invalida la cache en memoria (util al re-descargar el grafo)
  static void invalidateCache() {
    _memoryCache = null;
  }

  /// Distancia haversine en metros
  static double _haversine(
      double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dPhi = (lat2 - lat1) * pi / 180;
    final dLambda = (lng2 - lng1) * pi / 180;
    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}
