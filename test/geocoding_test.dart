import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/features/entities/data/datasources/geocoding_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/repositories/geocoding_repository_impl.dart';
import 'package:migra_ayuda/features/entities/domain/failures/geocoding_failure.dart';
import 'package:migra_ayuda/features/entities/domain/usecases/get_coordinates_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGeocodingDataSource extends Mock implements IGeocodingRemoteDataSource {}

void main() {
  late MockGeocodingDataSource mockPrimaryDataSource;
  late MockGeocodingDataSource mockFallbackDataSource;
  late GeocodingRepositoryImpl repository;
  late GetCoordinatesUseCase useCase;

  setUp(() {
    mockPrimaryDataSource = MockGeocodingDataSource();
    mockFallbackDataSource = MockGeocodingDataSource();
    repository = GeocodingRepositoryImpl(
      primaryDataSource: mockPrimaryDataSource,
      fallbackDataSource: mockFallbackDataSource,
    );
    useCase = GetCoordinatesUseCase(repository);
  });

  group('Geocoding Clean Architecture Tests', () {
    const testAddress = 'Calle 18 # 25-30';
    const expectedCoords = LatLng(1.2136, -77.2811);

    test('debería retornar coordenadas cuando el motor principal (Mapbox) responde exitosamente', () async {
      when(() => mockPrimaryDataSource.getCoordinates(any()))
          .thenAnswer((_) async => expectedCoords);

      final result = await useCase(testAddress);

      expect(result, const Right(expectedCoords));
      verify(() => mockPrimaryDataSource.getCoordinates('Calle 18 # 25-30, Pasto, Nariño, Colombia')).called(1);
      verifyZeroInteractions(mockFallbackDataSource);
    });

    test('debería usar motor de respaldo (Nominatim) cuando el principal devuelve null', () async {
      when(() => mockPrimaryDataSource.getCoordinates(any()))
          .thenAnswer((_) async => null);
      when(() => mockFallbackDataSource.getCoordinates(any()))
          .thenAnswer((_) async => expectedCoords);

      final result = await useCase(testAddress);

      expect(result, const Right(expectedCoords));
      verify(() => mockPrimaryDataSource.getCoordinates('Calle 18 # 25-30, Pasto, Nariño, Colombia')).called(1);
      verify(() => mockFallbackDataSource.getCoordinates('Calle 18 # 25-30, Pasto, Nariño, Colombia')).called(1);
    });

    test('debería retornar AddressNotFoundFailure cuando ambos motores fallan', () async {
      when(() => mockPrimaryDataSource.getCoordinates(any()))
          .thenAnswer((_) async => null);
      when(() => mockFallbackDataSource.getCoordinates(any()))
          .thenAnswer((_) async => null);

      final result = await useCase(testAddress);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AddressNotFoundFailure>()),
        (_) => fail('Debería retornar failure'),
      );
    });

    test('debería retornar InvalidAddressFormatFailure cuando la dirección está vacía', () async {
      final result = await useCase('   ');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidAddressFormatFailure>()),
        (_) => fail('Debería retornar failure'),
      );
    });
  });
}
