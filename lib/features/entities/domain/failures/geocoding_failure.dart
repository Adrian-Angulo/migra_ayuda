import 'package:migra_ayuda/core/errors/failure.dart';

abstract class GeocodingFailure extends Failure {
  const GeocodingFailure({required super.message, super.code});
}

class AddressNotFoundFailure extends GeocodingFailure {
  const AddressNotFoundFailure({
    super.message = 'No se encontró la ubicación para la dirección indicada.',
    super.code = 'address-not-found',
  });
}

class InvalidAddressFormatFailure extends GeocodingFailure {
  const InvalidAddressFormatFailure({
    super.message = 'El formato de la dirección ingresada no es válido.',
    super.code = 'invalid-address-format',
  });
}

class GeocodingServiceFailure extends GeocodingFailure {
  const GeocodingServiceFailure({
    super.message = 'Ocurrió un error al consultar el servicio de geocodificación.',
    super.code = 'geocoding-service-error',
  });
}
