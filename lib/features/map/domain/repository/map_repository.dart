import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/map/domain/entities/route_result.dart';

abstract class MapRepository {
  Future<Either<Failure, LatLng?>> getCoordinates(String address);

  Future<RouteResult> calculateRoute({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
  });
}