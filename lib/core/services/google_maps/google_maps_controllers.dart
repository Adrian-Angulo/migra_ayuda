import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/services/google_maps/google_maps_service.dart';
import 'package:migra_ayuda/core/services/google_maps/star_navegation_usecase.dart';

final googleMapsService = Provider<GoogleMapsNavigationService>(
    (ref) => GoogleMapsNavigationService());

final starNavigationUsecase = Provider<StarNavigationUsecase>((ref) =>
    StarNavigationUsecase(googleService: ref.watch(googleMapsService)));

final starNavigationNotifierProvider =
    AsyncNotifierProvider<StarNavigationNotifier, void>(
        StarNavigationNotifier.new);

class StarNavigationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> starNavigation(double latitude, double longitude) async {
    state = const AsyncValue.loading();
    final usecase = ref.watch(starNavigationUsecase);
    final result = await usecase(latitude, longitude);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}


