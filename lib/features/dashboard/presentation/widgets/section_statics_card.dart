import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/statistic_card.dart';


class SectionStaticsCard extends ConsumerWidget {
  const SectionStaticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersCountProvider);
    final entityState = ref.watch(entitiesCountProvider);
    final reviewState = ref.watch(reviewCountProvider);
    final servicesState = ref.watch(servicesCountProvider);

    final cards = [
      StatisticCard(
        title: 'Usuarios Registrados',
        value: usersState,
        icon: Icons.group_sharp,
      ),
      StatisticCard(
        title: 'Entidades registradas',
        value: entityState,
        icon: Icons.business,
      ),
      StatisticCard(
        title: 'Reseñas realizadas',
        value: reviewState,
        icon: Icons.comment,
      ),
      StatisticCard(
        title: 'Acciones ruta solicitada',
        value: servicesState,
        icon: Icons.filter_alt,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // En pantallas grandes (>= 1100 px): 4 tarjetas en fila uniforme
        if (constraints.maxWidth >= 1100) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }

        // En pantallas medianas (600 a 1100 px): Cuadrícula 2 x 2
        if (constraints.maxWidth >= 600) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }

        // En pantallas móviles (< 600 px): Apiladas en vertical
        return Column(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              cards[i],
            ],
          ],
        );
      },
    );
  }
}
