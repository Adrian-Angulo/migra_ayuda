import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/core/utils/utils.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/chart_data.dart';
import 'package:migra_ayuda/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActivityChartCard extends ConsumerWidget {
  const ActivityChartCard({super.key});

  Future<void> _selectCustomRange(BuildContext context, WidgetRef ref) async {
    final currentRange = ref.read(activityDateRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: currentRange,
      helpText: 'Seleccionar rango de fechas',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 520,
            ),
            child: Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: child,
            ),
          ),
        );
      },
    );
    if (picked != null) {
      ref.read(activityDateRangeProvider.notifier).state = picked;
    }
  }

  void _selectDays(WidgetRef ref, int days) {
    final now = DateTime.now();
    ref.read(activityDateRangeProvider.notifier).state = DateTimeRange(
      start: now.subtract(Duration(days: days)),
      end: now,
    );
  }

  Widget _buildRangeSelector(BuildContext context, WidgetRef ref) {
    final currentRange = ref.watch(activityDateRangeProvider);
    final startLabel = Utils.formatDia(currentRange.start);
    final endLabel = Utils.formatDia(currentRange.end);

    return PopupMenuButton<String>(
      tooltip: 'Filtrar por rango de fechas',
      onSelected: (value) {
        switch (value) {
          case '7':
            _selectDays(ref, 7);
            break;
          case '15':
            _selectDays(ref, 15);
            break;
          case '30':
            _selectDays(ref, 30);
            break;
          case 'custom':
            _selectCustomRange(context, ref);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: '7',
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text('Últimos 7 días'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: '15',
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text('Últimos 15 días'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: '30',
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text('Últimos 30 días'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'custom',
          child: Row(
            children: [
              Icon(Icons.date_range, size: 16, color: Colors.blue),
              SizedBox(width: 8),
              Text('Personalizado...'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: Colors.blueGrey,
            ),
            const SizedBox(width: 6),
            Text(
              '$startLabel - $endLabel',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: Colors.blueGrey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartAsync = ref.watch(activityChartProvider);

    return FadeInUp(
      child: Container(
        decoration: ContainerDecorationBorder.decorationBox(),
        height: 450,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Actividades por día',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildRangeSelector(context, ref),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: chartAsync.when(
                error: (error, stackTrace) => Center(
                  child: Text(
                    error is Failure
                        ? error.message
                        : 'No se pudieron cargar los datos de los gráficos',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                loading: () => const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
                data: (result) => SfCartesianChart(
                  legend: const Legend(
                    isVisible: true,
                    position: LegendPosition.top,
                    alignment: ChartAlignment.near,
                    iconBorderWidth: 10,
                  ),
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                  ),
                  primaryXAxis: const CategoryAxis(
                    labelRotation: -45,
                    labelIntersectAction: AxisLabelIntersectAction.hide,
                    majorGridLines: MajorGridLines(width: 0),
                    labelStyle: TextStyle(fontSize: 11),
                  ),
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
    );
  }
}
