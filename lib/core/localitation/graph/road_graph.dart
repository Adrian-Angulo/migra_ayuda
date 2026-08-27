import 'dart:math';

/// Nodo del grafo vial (interseccion u punto de la via)
class RoadNode {
  final String id;
  final double lat;
  final double lng;

  const RoadNode({required this.id, required this.lat, required this.lng});
}

/// Arista del grafo (segmento de via entre dos nodos)
class RoadEdge {
  final String to;
  final double weight; // distancia en metros

  const RoadEdge({required this.to, required this.weight});
}

/// Grafo vial completo con nodos y lista de adyacencia
class RoadGraph {
  final Map<String, RoadNode> nodes;
  final Map<String, List<RoadEdge>> adjacency;

  const RoadGraph({required this.nodes, required this.adjacency});

  bool get isEmpty => nodes.isEmpty;

  /// Retorna el ID del nodo mas cercano a las coordenadas dadas
  String? nearestNode(double lat, double lng) {
    if (nodes.isEmpty) return null;

    String? nearest;
    double minDist = double.infinity;

    for (final node in nodes.values) {
      final dist = _haversine(lat, lng, node.lat, node.lng);
      if (dist < minDist) {
        minDist = dist;
        nearest = node.id;
      }
    }

    return nearest;
  }

  /// Serializacion compacta para almacenamiento en Sembast
  Map<String, dynamic> toCompactJson() {
    final nodesMap = <String, dynamic>{};
    for (final n in nodes.values) {
      nodesMap[n.id] = [n.lat, n.lng];
    }

    final edgesMap = <String, dynamic>{};
    for (final entry in adjacency.entries) {
      edgesMap[entry.key] =
          entry.value.map((e) => [e.to, e.weight]).toList();
    }

    return {'nodes': nodesMap, 'edges': edgesMap};
  }

  /// Deserializa el grafo desde el formato compacto almacenado en Sembast
  factory RoadGraph.fromCompactJson(Map<String, dynamic> json) {
    final nodes = <String, RoadNode>{};
    final adjacency = <String, List<RoadEdge>>{};

    final nodesJson = json['nodes'] as Map<String, dynamic>;
    for (final entry in nodesJson.entries) {
      final coords = entry.value as List<dynamic>;
      nodes[entry.key] = RoadNode(
        id: entry.key,
        lat: (coords[0] as num).toDouble(),
        lng: (coords[1] as num).toDouble(),
      );
    }

    final edgesJson = json['edges'] as Map<String, dynamic>;
    for (final entry in edgesJson.entries) {
      final edgeList = entry.value as List<dynamic>;
      adjacency[entry.key] = edgeList.map((e) {
        final edge = e as List<dynamic>;
        return RoadEdge(
          to: edge[0] as String,
          weight: (edge[1] as num).toDouble(),
        );
      }).toList();
    }

    return RoadGraph(nodes: nodes, adjacency: adjacency);
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
