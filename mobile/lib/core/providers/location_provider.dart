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

/// Provider que calcula la distancia entre dos puntos geográficos.
///
/// Recibe un [map] con las siguientes claves:
/// - `start`: posición de origen ([Position])
/// - `endLatitude`: latitud del destino ([double])
/// - `endLongitude`: longitud del destino ([double])
///
/// Retorna la distancia formateada como [String].
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
