import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:migra_ayuda/core/services/locationService/location_service.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

/// Provider del servicio de ubicación.
/// Crea y expone una instancia de [LocationService] para toda la app.
final locationServiceProvider = Provider<LocationService>((ref) {
  // Creamos una sola instancia del servicio que se reutilizará
  final service = LocationService();
  return service;
});

/// Provider que emite la posición del usuario en tiempo real.
/// Usa [StreamNotifierProvider] para manejar el stream de ubicación.
final liveLocationProvider =
    StreamNotifierProvider<LiveLocationNotifier, Position>(
        LiveLocationNotifier.new);

/// Provider que calcula la distancia entre la posición actual del usuario y una entidad.
///
/// Observa [liveLocationProvider] para obtener la posición en tiempo real y
/// usa [LocationService.distance] para calcular la distancia hasta [entity].
///
/// Retorna:
/// - La distancia formateada como [String] cuando hay datos disponibles.
/// - `'--'` si ocurre un error.
/// - `'...'` mientras se carga la posición.
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

/// Notifier que gestiona el stream de posición en vivo del usuario.
///
/// Se encarga de verificar los permisos de ubicación antes de
/// comenzar a emitir posiciones actualizadas.
class LiveLocationNotifier extends StreamNotifier<Position> {
  /// Construye el stream de ubicación en tiempo real.
  ///
  /// 1. Verifica que la app tenga permisos de ubicación.
  /// 2. Emite posiciones continuas usando [LocationService.livePosition].
  @override
  Stream<Position> build() async* {
    // Obtenemos el servicio de ubicación
    final service = ref.watch(locationServiceProvider);

    // Verificamos y solicitamos permisos antes de iniciar el stream
    await service.checkPemission();

    // Iniciamos el stream que emite la posición actual del usuario
    yield* service.livePosition();
  }
}
