import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/map/data/datasources/mapbox_datasource.dart';
import 'package:migra_ayuda/features/map/domain/entities/route_result.dart';
import 'package:migra_ayuda/features/map/domain/failures/map_failures.dart';
import 'package:migra_ayuda/features/map/domain/repository/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  final MapboxDatasource _mapboxDatasource;

  MapRepositoryImpl({MapboxDatasource? mapboxDatasource})
      : _mapboxDatasource = mapboxDatasource ?? MapboxDatasource();

  @override
  Future<Either<Failure, LatLng?>> getCoordinates(String address) async {
    try {
      final LatLng? coordinates = await _mapboxDatasource.getCoordinates(address);
      return Right(coordinates);
    } catch (_) {
      return const Left(MapGeocodingFailure());
    }
  }

  @override
  Future<RouteResult> calculateRoute({
    required double originLng,
    required double originLat,
    required double destLng,
    required double destLat,
  }) async {
    try {
      final points = await _mapboxDatasource.getWalkingDirections(
        originLng: originLng,
        originLat: originLat,
        destLng: destLng,
        destLat: destLat,
      );

      if (points != null && points.isNotEmpty) {
        return RouteResult(
          points: points,
          sourceType: RouteSourceType.mapboxApi,
          message: 'Ruta trazada correctamente',
        );
      }
    } catch (_) {
      // Falla de red, timeout o respuesta no válida: continúa con la estrategia de fallback
    }

    return RouteResult(
      points: [
        Position(originLng, originLat),
        Position(destLng, destLat),
      ],
      sourceType: RouteSourceType.directFallback,
      message: 'Sin conexión: Línea directa de orientación al destino',
    );
  }
}
