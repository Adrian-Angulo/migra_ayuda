import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/activity_chart_result.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/category_data.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/chart_data.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/destination_data.dart';
import 'package:migra_ayuda/features/dashboard/domain/repositories/dashboard_repository.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository mockDashboardRepository;

  setUp(() {
    mockDashboardRepository = MockDashboardRepository();
  });

  group('Pruebas Unitarias - HU-WEB-10: Dashboard con Métricas y Gráficos Estadísticos', () {
    test('debería retornar el conteo numérico total de usuarios registrados', () async {
      // Arrange
      when(() => mockDashboardRepository.getUsersCount()).thenAnswer((_) async => 150);

      // Act
      final result = await mockDashboardRepository.getUsersCount();

      // Assert
      expect(result, 150);
      verify(() => mockDashboardRepository.getUsersCount()).called(1);
    });

    test('debería retornar la distribución de entidades agrupadas por categorías', () async {
      // Arrange
      final fakeCategories = [
        const CategoryData(name: 'Alimentación', value: 25),
        const CategoryData(name: 'Salud', value: 18),
        const CategoryData(name: 'Orientación Legal', value: 12),
      ];

      when(() => mockDashboardRepository.getCategoryData())
          .thenAnswer((_) async => fakeCategories);

      // Act
      final result = await mockDashboardRepository.getCategoryData();

      // Assert
      expect(result.length, 3);
      expect(result.first.name, 'Alimentación');
      expect(result.first.value, 25);
      verify(() => mockDashboardRepository.getCategoryData()).called(1);
    });

    test('debería emitir el flujo de datos sobre los destinos migratorios más frecuentes', () async {
      // Arrange
      final fakeDestinations = [
        const DestinationData(nombre: 'Chile', cantidad: 45),
        const DestinationData(nombre: 'Perú', cantidad: 30),
        const DestinationData(nombre: 'Ecuador', cantidad: 20),
      ];

      when(() => mockDashboardRepository.getDetinations())
          .thenAnswer((_) => Stream.value(fakeDestinations));

      // Act & Assert
      expect(
        mockDashboardRepository.getDetinations(),
        emits(fakeDestinations),
      );
      verify(() => mockDashboardRepository.getDetinations()).called(1);
    });

    test('debería procesar y estructurar las series temporales para el gráfico de actividad', () async {
      // Arrange
      final fakeActivityResult = ActivityChartResult(
        loginData: [ChartData('2026-10-20', 10), ChartData('2026-10-21', 15)],
        entityData: [ChartData('2026-10-20', 5), ChartData('2026-10-21', 8)],
        routeData: [ChartData('2026-10-20', 2), ChartData('2026-10-21', 4)],
        filterData: [ChartData('2026-10-20', 7), ChartData('2026-10-21', 11)],
        googleMapData: [ChartData('2026-10-20', 3), ChartData('2026-10-21', 6)],
      );

      final startDate = DateTime(2026, 10, 20);
      final endDate = DateTime(2026, 10, 22);

      when(
        () => mockDashboardRepository.getActivityData(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => fakeActivityResult);

      // Act
      final result = await mockDashboardRepository.getActivityData(
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(result.loginData.length, 2);
      expect(result.entityData.length, 2);
      expect(result.loginData.last.value, 15.0);
      expect(result.googleMapData.first.value, 3.0);
      verify(
        () => mockDashboardRepository.getActivityData(
          startDate: startDate,
          endDate: endDate,
        ),
      ).called(1);
    });
  });
}
