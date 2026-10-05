import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/errors/failure.dart';

abstract class IGeocodingRepository {
  /// Convierte una dirección de texto en coordenadas geográficas (Latitud, Longitud).
  Future<Either<Failure, LatLng>> getCoordinatesFromAddress(String address);
}
