import 'package:latlong2/latlong.dart';

abstract class GeoRepository {
  Future<LatLng?> searchCoordinates(String address);
  
}
