import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/entities/domain/failures/geocoding_failure.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/geocoding_repository.dart';

class GetCoordinatesUseCase {
  final IGeocodingRepository repository;

  GetCoordinatesUseCase(this.repository);

  Future<Either<Failure, LatLng>> call(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) {
      return const Left(InvalidAddressFormatFailure());
    }

    String sanitized = trimmed;
    final lower = trimmed.toLowerCase();
    if (!lower.contains('pasto') &&
        !lower.contains('nariño') &&
        !lower.contains('colombia')) {
      sanitized = '$trimmed, Pasto, Nariño, Colombia';
    }

    return await repository.getCoordinatesFromAddress(sanitized);
  }
}
