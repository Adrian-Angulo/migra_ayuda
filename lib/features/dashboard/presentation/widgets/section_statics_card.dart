import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/statistic_card.dart';

class StaticCard {
  final String titulo;
  final String value;
  final Widget icon;

  StaticCard({required this.titulo, required this.value, required this.icon});
}

class SectionStaticsCard extends ConsumerWidget {
  const SectionStaticsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersCountProvider);
    final entityState = ref.watch(entitiesCountProvider);
    final reviewState = ref.watch(reviewCountProvider);
    final servicesState = ref.watch(servicesCountProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      /* spacing: 16, */
      children: [
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
           
            )
      ],
    );
  }
}
