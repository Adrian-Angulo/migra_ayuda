import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/utils/utils.dart';

final imagenSelectProvider = StateProvider<XFile?>((ref) => null);
final imagenInBytesProvider = StateProvider<Uint8List?>((ref) => null);
final messageErrorImageProvider = StateProvider<String?>(
  (ref) => null,
);

final listSelectedServicesFormProviders = StateProvider<List<String>>((ref) => [],); 

class GeocodingNotifier extends AsyncNotifier<LatLng?> {
  @override
  Future<LatLng?> build() async => null; // estado inicial, sin búsqueda

  Future<void> search(String address) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => Utils.getCoordinates(address),
    );
  }
}

final geocodingProvider =
    AsyncNotifierProvider<GeocodingNotifier, LatLng?>(GeocodingNotifier.new);