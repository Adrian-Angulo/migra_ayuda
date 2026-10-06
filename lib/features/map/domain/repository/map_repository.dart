import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/errors/failure.dart';

abstract class MapRepository {
  Future<Either<Failure, LatLng?>> getCoordinates(String address);
}