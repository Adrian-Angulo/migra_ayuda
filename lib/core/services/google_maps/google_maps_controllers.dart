import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/services/google_maps/google_maps_service.dart';
import 'package:migra_ayuda/features/userActivity/presentation/providers/activities_providers.dart';

final googleMapsService = Provider<GoogleMapsNavigationService>(
    (ref) => GoogleMapsNavigationService());

final starNavigationNotifierProvider =
    AsyncNotifierProvider<StarNavigationNotifier, void>(
        StarNavigationNotifier.new);

class StarNavigationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> starNavigation(double latitude, double longitude) async {
    state = const AsyncValue.loading();

    await ref.read(googleMapsService).startNavigation(latitude, longitude);
    await ref.read(activityProvider.notifier).create(
          accion: ActivityActions.navigationMaps(),
        );
  }
}
