import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/widgets/web/statistic_card.dart';

class SectionStaticsCard extends StatelessWidget {
  const SectionStaticsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      /* spacing: 16, */
      children: [
        StatisticCard(
            title: 'Usuarios Registrados',
            value: '1,22',
            icon: Icons.people_outline),
        StatisticCard(
            title: 'Usuarios Registrados',
            value: '1,22',
            icon: Icons.people_outline),
        StatisticCard(
            title: 'Usuarios Registrados',
            value: '1,22',
            icon: Icons.people_outline),
        StatisticCard(
            title: 'Usuarios Registrados',
            value: '1,22',
            icon: Icons.people_outline)
      ],
    );
  }
}
