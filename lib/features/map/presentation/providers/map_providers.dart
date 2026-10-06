import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/map/data/repository/map_repository_impl.dart';
import 'package:migra_ayuda/features/map/domain/usecases/map_usecase.dart';
import 'package:latlong2/latlong.dart';

final mapRepositoryProvider = Provider<MapRepositoryImpl>((ref) {
  return MapRepositoryImpl();
});


final getCoordinatesUsecaseProvider = Provider<GetCoordinatesUsecase>((ref) {
  final mapRepository = ref.watch(mapRepositoryProvider);
  return GetCoordinatesUsecase(mapRepository);
});


class CoordinatesNotifier extends AsyncNotifier<LatLng?> {
  @override
  Future<LatLng?> build() async {
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

  void setCoordinate(LatLng coordinates) {
    state = AsyncValue.data(coordinates);
  }
}

final coordinatesNotifierProvider =
    AsyncNotifierProvider<CoordinatesNotifier, LatLng?>(() => CoordinatesNotifier());

