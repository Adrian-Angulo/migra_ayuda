import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Origen de la ruta calculada.
enum RouteSourceType { mapboxApi, directFallback }

/// Representa el resultado del cálculo de una ruta peatonal.
class RouteResult {
  final List<Position> points;
  final RouteSourceType sourceType;
  final String message;

  const RouteResult({
    required this.points,
    required this.sourceType,
    required this.message,
  });

  bool get isOffline => sourceType == RouteSourceType.directFallback;
  bool get isFallback => isOffline;
  bool get isOnline => sourceType == RouteSourceType.mapboxApi;
  bool get isStreetRoute => isOnline;
}
