import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:migra_ayuda/features/map/data/datasources/mapbox_datasource.dart';
import 'package:migra_ayuda/features/map/data/repository/map_repository_impl.dart';
import 'package:migra_ayuda/features/map/domain/entities/route_result.dart';
import 'package:migra_ayuda/features/map/domain/usecases/calculate_route_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockMapboxDatasource extends Mock implements MapboxDatasource {}

void main() {
  late MockMapboxDatasource mockDatasource;
  late MapRepositoryImpl repository;
  late CalculateRouteUseCase useCase;

  setUp(() {
    mockDatasource = MockMapboxDatasource();
    repository = MapRepositoryImpl(mapboxDatasource: mockDatasource);
    useCase = CalculateRouteUseCase(repository);
  });

  const originLng = -77.2811;
  const originLat = 1.2136;
  const destLng = -77.2750;
  const destLat = 1.2180;

  group('CalculateRouteUseCase & MapRepositoryImpl', () {
    test(
      'éxito: debería retornar RouteSourceType.mapboxApi cuando el datasource responde con puntos',
      () async {
        final fakePoints = [
          Position(originLng, originLat),
          Position(-77.2780, 1.2150),
          Position(destLng, destLat),
        ];

        when(() => mockDatasource.getWalkingDirections(
              originLng: originLng,
              originLat: originLat,
              destLng: destLng,
              destLat: destLat,
            )).thenAnswer((_) async => fakePoints);

        final result = await useCase(
          originLng: originLng,
          originLat: originLat,
          destLng: destLng,
          destLat: destLat,
        );

        expect(result.sourceType, RouteSourceType.mapboxApi);
        expect(result.isOnline, true);
        expect(result.isOffline, false);
        expect(result.points.length, 3);
        expect(result.points, fakePoints);
      },
    );

    test(
      'fallback: debería retornar RouteSourceType.directFallback con 2 puntos cuando el datasource retorna null',
      () async {
        when(() => mockDatasource.getWalkingDirections(
              originLng: originLng,
              originLat: originLat,
              destLng: destLng,
              destLat: destLat,
            )).thenAnswer((_) async => null);

        final result = await useCase(
          originLng: originLng,
          originLat: originLat,
          destLng: destLng,
          destLat: destLat,
        );

        expect(result.sourceType, RouteSourceType.directFallback);
        expect(result.isOffline, true);
        expect(result.isFallback, true);
        expect(result.points.length, 2);
        expect(result.points.first.lng, originLng);
        expect(result.points.first.lat, originLat);
        expect(result.points.last.lng, destLng);
        expect(result.points.last.lat, destLat);
      },
    );

    test(
      'fallback: debería retornar RouteSourceType.directFallback cuando el datasource lanza una excepción',
      () async {
        when(() => mockDatasource.getWalkingDirections(
              originLng: originLng,
              originLat: originLat,
              destLng: destLng,
              destLat: destLat,
            )).thenThrow(Exception('Network timeout'));

        final result = await useCase(
          originLng: originLng,
          originLat: originLat,
          destLng: destLng,
          destLat: destLat,
        );

        expect(result.sourceType, RouteSourceType.directFallback);
        expect(result.isOffline, true);
        expect(result.points.length, 2);
      },
    );
  });
}
