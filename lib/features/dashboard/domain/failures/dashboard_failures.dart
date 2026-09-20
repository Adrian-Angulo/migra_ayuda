import 'package:migra_ayuda/core/errors/failure.dart';

abstract class DashboardFailure extends Failure {
  const DashboardFailure({required super.message, super.code});
}

class DashboardMetricsFetchFailure extends DashboardFailure {
  const DashboardMetricsFetchFailure({
    super.message = 'No se pudieron cargar las estadísticas del dashboard',
    super.code = 'dashboard-metrics-fetch-failed',
  });
}

class DashboardChartDataFetchFailure extends DashboardFailure {
  const DashboardChartDataFetchFailure({
    super.message = 'No se pudieron cargar los datos de los gráficos',
    super.code = 'dashboard-chart-data-fetch-failed',
  });
}

class DashboardDestinationsFetchFailure extends DashboardFailure {
  const DashboardDestinationsFetchFailure({
    super.message = 'No se pudo cargar la información de destinos',
    super.code = 'dashboard-destinations-fetch-failed',
  });
}

class GenericDashboardFailure extends DashboardFailure {
  const GenericDashboardFailure({
    required super.message,
    super.code,
  });
}
