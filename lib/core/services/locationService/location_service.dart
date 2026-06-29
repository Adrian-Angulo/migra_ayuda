import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<void> checkPemission() async {
    bool isEnableGPS = await Geolocator.isLocationServiceEnabled();
    if (!isEnableGPS) {
      throw ('El GPS esta desactivado, porfavor enciendalo');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicacion estan denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Los servicicos estan denegados por siempre, cambialos en la configuracion del dispositivo',
      );
    }
  }

  Future<Position> getPosition() async {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Stream<Position> livePosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    );
  }

  String distance(
      {required Position start,
      required double endLatitude,
      required double endLongitude}) {
    final double meters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      endLatitude,
      endLongitude,
    );
    if (meters >= 1000) {
      final double km = meters / 1000;
      return '${km.toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(1)} m';
  }
}
