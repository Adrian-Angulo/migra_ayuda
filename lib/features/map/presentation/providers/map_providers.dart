import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/features/map/data/repository/map_repository_impl.dart';
import 'package:migra_ayuda/features/map/domain/entities/geocoding_result.dart';
import 'package:migra_ayuda/features/map/domain/repository/map_repository.dart';
import 'package:migra_ayuda/features/map/domain/usecases/calculate_route_usecase.dart';
import 'package:migra_ayuda/features/map/domain/usecases/map_usecase.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepositoryImpl();
});

final getCoordinatesUsecaseProvider = Provider<GetCoordinatesUsecase>((ref) {
  final mapRepository = ref.watch(mapRepositoryProvider);
  return GetCoordinatesUsecase(mapRepository);
});

final calculateRouteUseCaseProvider = Provider<CalculateRouteUseCase>((ref) {
  final mapRepository = ref.watch(mapRepositoryProvider);
  return CalculateRouteUseCase(mapRepository);
});

class CoordinatesNotifier extends AsyncNotifier<GeocodingResult?> {
  @override
  GeocodingResult? build() {
    return null;
  }

  Future<void> getCoordinates(String address) async {
    final getCoordinatesUsecase = ref.read(getCoordinatesUsecaseProvider);
    state = const AsyncValue.loading();
    final result = await getCoordinatesUsecase(address);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (coordinates) => state = AsyncValue.data(coordinates),
    );
  }

  void setCoordinate(
    LatLng coordinates, {
    String? placeName,
    bool isManual = false,
  }) {
    state = AsyncValue.data(
      GeocodingResult(
        point: coordinates,
        placeName: placeName ??
            (isManual
                ? 'Ubicación ajustada manualmente en el mapa'
                : 'Ubicación confirmada'),
        isManualSelection: isManual,
      ),
    );
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final coordinatesNotifierProvider =
    AsyncNotifierProvider.autoDispose<CoordinatesNotifier, GeocodingResult?>(
        () => CoordinatesNotifier());
