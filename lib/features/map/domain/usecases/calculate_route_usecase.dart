import 'package:migra_ayuda/features/map/domain/entities/route_result.dart';
import 'package:migra_ayuda/features/map/domain/repository/map_repository.dart';

class CalculateRouteUseCase {
  final MapRepository repository;

  CalculateRouteUseCase(this.repository);

  Future<RouteResult> call({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
  }) {
    return repository.calculateRoute(
      originLng: originLng,
      originLat: originLat,
      destLng: destLng,
      destLat: destLat,
    );
  }
}
