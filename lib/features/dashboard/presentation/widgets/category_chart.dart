import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/category_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryChart extends StatelessWidget {
  const CategoryChart({
    super.key,
  });

  final List<CategoryData> data = const [
    CategoryData(
      name: 'Salud',
      value: 96,
      color: Color(0xFF3F78C5),
    ),
    CategoryData(
      name: 'Empleo',
      value: 75,
      color: Color(0xFF2E8B57),
    ),
    CategoryData(
      name: 'Educación',
      value: 62,
      color: Color(0xFF8E63C7),
    ),
    CategoryData(
      name: 'Legal',
      value: 51,
      color: Color(0xFFD68A1F),
    ),
    CategoryData(
      name: 'Vivienda',
      value: 34,
      color: Color(0xFFD96F22),
    ),
    CategoryData(
      name: 'Otros',
      value: 24,
      color: Color(0xFF8C8C8C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(
      0,
      (sum, item) => sum + item.value,
    );

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
            Row(
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
                                '$total',
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
                          pointColorMapper: (item, _) => item.color,

                          // Grosor parecido a la imagen
                          innerRadius: '72%',
                          radius: '92%',

                          // Quitamos labels
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: false,
                          ),
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
                      final percent = item.value / total * 100;

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
                                color: item.color,
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
            ),
          ],
        ),
      ),
    );
  }
}
