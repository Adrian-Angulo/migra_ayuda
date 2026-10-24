import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/widgets/web/dasboard_header.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/activity_chart_card.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/category_chart.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/recent_activities.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/section_statics_card.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/service_more_filter_container.dart';


class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth >= 1024;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const HeaderWeb(title: 'Dashboard', subTitle: 'Resumen general'),
                const SizedBox(height: 24),

                // Secciones de tarjetas métricas
                const SectionStaticsCard(),
                const SizedBox(height: 24),

                // Sección de gráficos de actividad y actividades recientes
                if (isWideScreen)
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: ActivityChartCard()),
                      SizedBox(width: 16),
                      Expanded(flex: 1, child: RecentActivities()),
                    ],
                  )
                else ...[
                  const ActivityChartCard(),
                  const SizedBox(height: 24),
                  const RecentActivities(),
                ],
                const SizedBox(height: 24),

                // Sección de categorías y destinos más requeridos
                if (isWideScreen)
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: CategoryChart()),
                      SizedBox(width: 16),
                      Expanded(child: ServiceMoreFilterContainer()),
                    ],
                  )
                else ...[
                  const CategoryChart(),
                  const SizedBox(height: 24),
                  const ServiceMoreFilterContainer(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
