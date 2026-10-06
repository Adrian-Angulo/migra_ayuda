import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/map/data/datasources/mapbox_datasource.dart';
import 'package:migra_ayuda/features/map/domain/failures/map_failures.dart';
import 'package:migra_ayuda/features/map/domain/repository/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  final MapboxDatasource _mapboxDatasource = MapboxDatasource();

  @override
  Future<Either<Failure, LatLng?>> getCoordinates(String address) async {
    try {
      final LatLng? coordinates = await _mapboxDatasource.getCoordinates(address);
      return Right(coordinates);
    } catch (_) {
      return const Left(MapGeocodingFailure());
    }
  }
}
