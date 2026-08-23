import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/chart_data.dart';
import 'package:migra_ayuda/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActivityChartCard extends ConsumerWidget {
  const ActivityChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     final chartAsync = ref.watch(activityChartProvider);

    return chartAsync.when( error: (error, stackTrace) => FadeInUp(child: Center(child: Text('Error al cargar los datos ${error.toString()}'),)), loading: () => FadeInUp(
      child: Container(
        decoration: ContainerDecorationBorder.decorationBox(),
        height: 450,
        child: const Center(child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator()),)
      ),
    ), data: (result) {

      return 
FadeInUp(

  child: Container(
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
                    primaryXAxis: const CategoryAxis(),
                    primaryYAxis: const NumericAxis(minimum: 0),
                    series: [
                      LineSeries<ChartData, String>(
                          name: 'Inicio de Sesión',
                          dataSource: result.loginData,
                          xValueMapper: (data, _) => data.day,
                          yValueMapper: (data, _) => data.value,
                        ),
                        LineSeries<ChartData, String>(
                          name: 'Detalles de entidad',
                          dataSource: result.entityData,
                          xValueMapper: (data, _) => data.day,
                          yValueMapper: (data, _) => data.value,
                        ),
                        LineSeries<ChartData, String>(
                          name: 'Ruta solicitada',
                          dataSource: result.routeData,
                          xValueMapper: (data, _) => data.day,
                          yValueMapper: (data, _) => data.value,
                        ),
                        LineSeries<ChartData, String>(
                          name: 'Filtros',
                          dataSource: result.filterData,
                          xValueMapper: (data, _) => data.day,
                          yValueMapper: (data, _) => data.value,
                        ),
                        LineSeries<ChartData, String>(
                          name: 'Navegar por Google Maps',
                          dataSource: result.googleMapData,
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
      ),
); 
    } ,);
  }
}
