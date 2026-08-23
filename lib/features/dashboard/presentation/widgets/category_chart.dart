import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/category_data.dart';
import 'package:migra_ayuda/features/dashboard/presentation/providers/dashboard_providers.dart';

class CategoryChart extends ConsumerWidget {
  const CategoryChart({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateData = ref.watch(getCategoryDataProvider);
    final countEntitiesState = ref.watch(entitiesCountProvider);

    return FadeInUp(
      child: Container(
        height: 350,
        decoration: ContainerDecorationBorder.decorationBox(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entidades por categoría',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              stateData.when(
                data: (data) {
                  return countEntitiesState.when(
                    data: (count) {
                      if (count == 0) {
                        // Si el total está en 0 mostramos algo más adecuado
                        return const Center(
                          child:
                              Text('No hay entidades disponibles para mostrar.'),
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 250,
                              child: SfCircularChart(
                                annotations: [
                                  CircularChartAnnotation(
                                    widget: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$count',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'Total',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                series: [
                                  DoughnutSeries<CategoryData, String>(
                                    dataSource: data,
                                    xValueMapper: (item, _) => item.name,
                                    yValueMapper: (item, _) => item.value,
                                    pointColorMapper: (item, _) =>
                                        getServiceColor(item.name),
                                    innerRadius: '72%',
                                    radius: '92%',
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: false,
                                    ),
                                    enableTooltip: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: data.map((item) {
                                final percent =
                                    count > 0 ? (item.value / count) * 100 : 0.0;
      
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: getServiceColor(item.name),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${percent.round()}% (${item.value})',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => Container(
                      decoration: ContainerDecorationBorder.decorationBox(),
                      height: 350,
                    
                      child: const Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(height: 8),
                          const Text('No se pudo cargar el total de entidades'),
                          Text(
                            'Error: ${error.toString()}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 8),
                      const Text('Error al mostrar el gráfico'),
                      Text(
                        'Error: ${error.toString()}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
