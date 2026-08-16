import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActivityChartCard extends StatelessWidget {
  const ActivityChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loginData = [
      ChartData('1 May', 60),
      ChartData('6 May', 62),
      ChartData('11 May', 71),
      ChartData('16 May', 75),
      ChartData('21 May', 86),
      ChartData('26 May', 71),
      ChartData('31 May', 91),
    ];

    final entityData = [
      ChartData('1 May', 29),
      ChartData('6 May', 40),
      ChartData('11 May', 45),
      ChartData('16 May', 42),
      ChartData('21 May', 45),
      ChartData('26 May', 35),
      ChartData('31 May', 54),
    ];

    final routeData = [
      ChartData('1 May', 13),
      ChartData('6 May', 18),
      ChartData('11 May', 10),
      ChartData('16 May', 14),
      ChartData('21 May', 12),
      ChartData('26 May', 9),
      ChartData('31 May', 18),
    ];

    final filterData = [
      ChartData('1 May', 7),
      ChartData('6 May', 13),
      ChartData('11 May', 5),
      ChartData('16 May', 12),
      ChartData('21 May', 9),
      ChartData('26 May', 2),
      ChartData('31 May', 16),
    ];
    final googleMapData = [
      ChartData('1 May', 11),
      ChartData('6 May', 22),
      ChartData('11 May', 18),
      ChartData('16 May', 25),
      ChartData('21 May', 20),
      ChartData('26 May', 15),
      ChartData('31 May', 28),
    ];
    return Container(
      decoration: ContainerDecorationBorder.decorationBox(),
      height: 450,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actividades por día',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: SfCartesianChart(
                  legend: const Legend(
                    isVisible: true,
                    position: LegendPosition.top,
                    alignment: ChartAlignment.near,
                    iconBorderWidth: 10,
                  ),
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis:
                      const NumericAxis(minimum: 0, maximum: 100, interval: 5),
                  series: [
                    LineSeries<ChartData, String>(
                      name: 'Inicio de Sesión',
                      dataSource: loginData,
                      xValueMapper: (data, _) => data.day,
                      yValueMapper: (data, _) => data.value,
                    ),
                    LineSeries<ChartData, String>(
                      name: 'Detalles de entidad',
                      dataSource: entityData,
                      xValueMapper: (data, _) => data.day,
                      yValueMapper: (data, _) => data.value,
                    ),
                    LineSeries<ChartData, String>(
                      name: 'Ruta solicitada',
                      dataSource: routeData,
                      xValueMapper: (data, _) => data.day,
                      yValueMapper: (data, _) => data.value,
                    ),
                    LineSeries<ChartData, String>(
                      name: 'Filtros',
                      dataSource: filterData,
                      xValueMapper: (data, _) => data.day,
                      yValueMapper: (data, _) => data.value,
                    ),
                    LineSeries<ChartData, String>(
                      name: 'Navegar por google maps',
                      dataSource: googleMapData,
                      xValueMapper: (data, _) => data.day,
                      yValueMapper: (data, _) => data.value,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
