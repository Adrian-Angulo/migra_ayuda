import 'package:migra_ayuda/core/errors/failure.dart';

class MapGeocodingFailure extends Failure {
  const MapGeocodingFailure({super.message = 'Error al obtener coordenadas.'});
}
