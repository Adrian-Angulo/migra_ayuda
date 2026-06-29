import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/services/google_maps/google_maps_service.dart';

class StarNavigationUsecase {
  final GoogleMapsNavigationService googleService;

  StarNavigationUsecase({required this.googleService});

  Future<Either<String, void>> call(double latitud, double longitud) async {
    try {
      await googleService.startNavigation(latitud, longitud);
      return right(unit);
    } catch (e) {
      return left(e.toString());
    }
  }
}
