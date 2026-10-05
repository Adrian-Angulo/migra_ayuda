import 'package:latlong2/latlong.dart';

abstract class IGeocodingRemoteDataSource {
  Future<LatLng?> getCoordinates(String address);
}
