import 'dart:math';

import 'package:collection/collection.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'road_graph.dart';

/// Entrada para el PriorityQueue del algoritmo A*
class _AStarEntry implements Comparable<_AStarEntry> {
  final String nodeId;
  final double f; // g + h (coste acumulado + heuristica)

  const _AStarEntry(this.nodeId, this.f);

  @override
  int compareTo(_AStarEntry other) => f.compareTo(other.f);
}

/// Motor de calculo de rutas usando el algoritmo A*
/// sobre el grafo vial de OpenStreetMap almacenado localmente.
class RouteCalculator {
  final RoadGraph graph;

  const RouteCalculator(this.graph);

  /// Calcula la ruta mas corta entre origen y destino.
  ///
  /// Retorna una lista de [Position] (Mapbox SDK) con los puntos
  /// de la ruta por las calles reales de OSM.
  /// Retorna null si no se encuentra ruta.
  List<Position>? calculate({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    if (graph.isEmpty) return null;

    final startId = graph.nearestNode(originLat, originLng);
    final endId = graph.nearestNode(destLat, destLng);

    if (startId == null || endId == null) return null;

    // Caso trivial: origen y destino en el mismo nodo
    if (startId == endId) {
      return [
        Position(originLng, originLat),
        Position(destLng, destLat),
      ];
    }

    // A* con conjunto cerrado para manejar entradas duplicadas
    final closedSet = <String>{};
    final openSet = PriorityQueue<_AStarEntry>();
    final gScore = <String, double>{startId: 0.0};
    final cameFrom = <String, String>{};

    openSet.add(_AStarEntry(startId, _heuristic(startId, endId)));

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();

      // Ignorar entradas obsoletas del heap
      if (closedSet.contains(current.nodeId)) continue;
      closedSet.add(current.nodeId);

      if (current.nodeId == endId) {
        return _reconstructPath(
          cameFrom, current.nodeId,
          originLat, originLng, destLat, destLng,
        );
      }

      final neighbors = graph.adjacency[current.nodeId] ?? [];
      for (final edge in neighbors) {
        if (closedSet.contains(edge.to)) continue;

        final tentativeG =
            (gScore[current.nodeId] ?? double.infinity) + edge.weight;

        if (tentativeG < (gScore[edge.to] ?? double.infinity)) {
          cameFrom[edge.to] = current.nodeId;
          gScore[edge.to] = tentativeG;
          final f = tentativeG + _heuristic(edge.to, endId);
          openSet.add(_AStarEntry(edge.to, f));
        }
      }
    }

    return null; // No se encontro ruta
  }

  /// Heuristica A*: distancia haversine al nodo destino
  double _heuristic(String nodeId, String targetId) {
    final node = graph.nodes[nodeId];
    final target = graph.nodes[targetId];
    if (node == null || target == null) return 0;
    return _haversine(node.lat, node.lng, target.lat, target.lng);
  }

  /// Reconstruye la ruta desde el mapa cameFrom
  List<Position> _reconstructPath(
    Map<String, String> cameFrom,
    String end,
    double originLat, double originLng,
    double destLat, double destLng,
  ) {
    final path = <Position>[];
    String? curr = end;

    while (curr != null) {
      final node = graph.nodes[curr];
      if (node != null) {
        path.add(Position(node.lng, node.lat));
      }
      curr = cameFrom[curr];
    }

    // La ruta se construyo de destino a origen, la invertimos
    final result = path.reversed.toList();

    // Insertamos la coordenada GPS exacta del origen al inicio
    // y del destino al final para mayor precision
    if (result.isNotEmpty) {
      result.insert(0, Position(originLng, originLat));
      result.add(Position(destLng, destLat));
    }

    return result;
  }

  /// Distancia haversine en metros entre dos coordenadas
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
