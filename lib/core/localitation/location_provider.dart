import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:migra_ayuda/core/localitation/location_service.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

final locationServiceProvider = Provider<LocationService>((ref) {

  final service = LocationService();
  return service;
});


final liveLocationProvider =
    StreamNotifierProvider<LiveLocationNotifier, Position>(
        LiveLocationNotifier.new);


final distanceProvider = Provider.family<String, EntityEntity>(
  (ref, entity) {
    final service = ref.watch(locationServiceProvider);
    final locationAsync = ref.watch(liveLocationProvider);

    return locationAsync.when(
      data: (position) => service.distance(
        start: position,
        endLatitude: entity.localitation.latitude,
        endLongitude: entity.localitation.longitude,
      ),
      error: (error, stackTrace) => '--',
      loading: () => '...',
    );
  },
);


class LiveLocationNotifier extends StreamNotifier<Position> {

  @override
  Stream<Position> build() async* {
    final service = ref.watch(locationServiceProvider);
    await service.checkPemission();
    yield* service.livePosition();
  }
}
