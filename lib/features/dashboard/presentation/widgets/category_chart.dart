import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/category_data.dart';
import 'package:migra_ayuda/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryChart extends ConsumerWidget {
  CategoryChart({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateData = ref.watch(getCategoryDataProvider);
    final countEntitiesState = ref.watch(entitiesCountProvider);

    return Container(
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
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 180,
                        child: SfCircularChart(
                          annotations: [
                            CircularChartAnnotation(
                              widget: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${countEntitiesState.value ?? 0}',
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

                              // Grosor parecido a la imagen
                              innerRadius: '72%',
                              radius: '92%',

                              // Quitamos labels
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
                          //TODO: CAMBIAR ESTO EL TOTAL

                          final percent = item.value /
                              (countEntitiesState.value ?? 0) *
                              100;

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
              error: (error, stackTrace) => Center(
                child: Column(
                  children: [
                    const Text('Error al mostrar el grafico'),
                    Text('Error: ${error.toString()}'),
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
    );
  }
}
