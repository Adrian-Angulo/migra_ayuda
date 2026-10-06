import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/map/domain/repository/map_repository.dart';

class GetCoordinatesUsecase {
  final MapRepository repository;

  GetCoordinatesUsecase(this.repository);

  Future<Either<Failure, LatLng?>> call(String address) {
    return repository.getCoordinates(address);
  }
}
