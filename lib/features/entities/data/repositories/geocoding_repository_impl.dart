import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/entities/data/datasources/geocoding_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/domain/failures/geocoding_failure.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/geocoding_repository.dart';

class GeocodingRepositoryImpl implements IGeocodingRepository {
  final IGeocodingRemoteDataSource primaryDataSource;
  final IGeocodingRemoteDataSource? fallbackDataSource;

  GeocodingRepositoryImpl({
    required this.primaryDataSource,
    this.fallbackDataSource,
  });

  @override
  Future<Either<Failure, LatLng>> getCoordinatesFromAddress(String address) async {
    try {
      // 1. Intento con motor principal (Mapbox Places)
      final primaryCoords = await primaryDataSource.getCoordinates(address);
      if (primaryCoords != null) {
        return Right(primaryCoords);
      }

      // 2. Intento con motor de respaldo (Nominatim / OSM) si está configurado
      if (fallbackDataSource != null) {
        debugPrint('🔄 Mapbox no encontró la dirección, probando motor de respaldo...');
        final fallbackCoords = await fallbackDataSource!.getCoordinates(address);
        if (fallbackCoords != null) {
          return Right(fallbackCoords);
        }
      }

      return const Left(AddressNotFoundFailure());
    } catch (e) {
      debugPrint('❌ Error en GeocodingRepositoryImpl: $e');
      return const Left(GeocodingServiceFailure());
    }
  }
}
