import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/features/entities/data/datasources/nominatim_geocoding_datasource.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/geo_repository.dart';

class GeoRepositoryImpl implements GeoRepository {
  final geo = NominatimGeocodingDatasource();

  @override
  Future<LatLng?> searchCoordinates(String address) {
    return geo.getCoordinates(address);
  }
}
