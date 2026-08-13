import 'package:flutter/material.dart';

class ActivityChartCard extends StatelessWidget {
  const ActivityChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Actividades por día',
                style: TextStyle(
                  fontSize: 16,
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
      ),
    );
  }
}
