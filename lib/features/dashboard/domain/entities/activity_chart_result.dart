import 'package:migra_ayuda/features/dashboard/domain/entities/chart_data.dart';

class ActivityChartResult {
  final List<ChartData> loginData;
  final List<ChartData> entityData;
  final List<ChartData> routeData;
  final List<ChartData> filterData;
  final List<ChartData> googleMapData;

  ActivityChartResult({
    required this.loginData,
    required this.entityData,
    required this.routeData,
    required this.filterData,
    required this.googleMapData,
  });
}