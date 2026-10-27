import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/utils/helpers/address_normalizer.dart';
import 'package:migra_ayuda/core/utils/validators/address_validator.dart';
import 'package:migra_ayuda/features/map/data/datasources/mapbox_datasource.dart';
import 'package:migra_ayuda/features/map/data/repository/map_repository_impl.dart';
import 'package:migra_ayuda/features/map/domain/entities/geocoding_result.dart';
import 'package:migra_ayuda/features/map/domain/failures/map_failures.dart';
import 'package:migra_ayuda/features/map/domain/usecases/map_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockMapboxDatasource extends Mock implements MapboxDatasource {}

void main() {
  group('AddressNormalizer', () {
    test('debe expandir abreviaturas comunes y limpiar caracteres confusos', () {
      final input = 'Cra. 22 # 15-40, Pasto';
      final normalized = AddressNormalizer.normalize(input);

      expect(normalized.contains('Carrera 22 15-40'), isTrue);
      expect(normalized.contains('#'), isFalse);
      expect(normalized.toLowerCase().contains('pasto'), isTrue);
    });

    test('debe agregar la ciudad si no se incluye', () {
      final input = 'Calle 18 # 25-30';
      final normalized = AddressNormalizer.normalize(input);

      expect(normalized, 'Calle 18 25-30, Pasto');
    });

    test('debe normalizar avenidas, diagonales y transversales', () {
      expect(
        AddressNormalizer.normalize('Av. Panamericana # 10-20'),
        'Avenida Panamericana 10-20, Pasto',
      );
      expect(
        AddressNormalizer.normalize('Dg. 15 # 4-20, Pasto'),
        'Diagonal 15 4-20, Pasto',
      );
      expect(
        AddressNormalizer.normalize('Tv. 3 # 1-10, Pasto'),
        'Transversal 3 1-10, Pasto',
      );
    });
  });

  group('AddressValidator', () {
    test('debe retornar error si el campo está vacío', () {
      expect(AddressValidator.validate(''), isNotNull);
      expect(AddressValidator.validate('   '), isNotNull);
      expect(AddressValidator.validate(null), isNotNull);
    });

    test('debe retornar error si tiene menos de 5 caracteres', () {
      expect(AddressValidator.validate('Cl 1'), isNotNull);
    });

    test('debe aceptar direcciones estándar y puntos de interés', () {
      expect(AddressValidator.validate('Calle 18 # 25-30, Pasto'), isNull);
      expect(AddressValidator.validate('Carrera 22 15-40'), isNull);
      expect(AddressValidator.validate('Hospital San Pedro, Pasto'), isNull);
      expect(AddressValidator.validate('Plaza de Nariño'), isNull);
    });
  });

  group('Geocoding UseCase & Repository', () {
    late MockMapboxDatasource mockDatasource;
    late MapRepositoryImpl repository;
    late GetCoordinatesUsecase useCase;

    setUp(() {
      mockDatasource = MockMapboxDatasource();
      repository = MapRepositoryImpl(mapboxDatasource: mockDatasource);
      useCase = GetCoordinatesUsecase(repository);
    });

    test('debe retornar GeocodingResult cuando el datasource responde exitosamente', () async {
      const tResult = GeocodingResult(
        point: LatLng(1.2151, -77.2791),
        placeName: 'Calle 18 25-41, Pasto, Nariño, Colombia',
      );

      when(() => mockDatasource.getCoordinates(any()))
          .thenAnswer((_) async => tResult);

      final result = await useCase('Calle 18 # 25-30, Pasto');

      expect(result, const Right(tResult));
      verify(() => mockDatasource.getCoordinates('Calle 18 # 25-30, Pasto')).called(1);
    });

    test('debe retornar MapGeocodingFailure cuando el datasource lanza excepción', () async {
      when(() => mockDatasource.getCoordinates(any()))
          .thenThrow(Exception('Network error'));

      final result = await useCase('Dirección Inválida');

      expect(result, const Left(MapGeocodingFailure()));
    });
  });
}
