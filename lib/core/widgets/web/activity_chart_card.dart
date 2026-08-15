import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';

class ActivityChartCard extends StatelessWidget {
  const ActivityChartCard({super.key});

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('Aquí irá el gráfico'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
