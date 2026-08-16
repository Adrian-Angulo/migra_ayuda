import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/widgets/web/dasboard_header.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/activity_chart_card.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/entity_for_category.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/recent_activities.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/section_statics_card.dart';
import 'package:migra_ayuda/features/dashboard/presentation/widgets/service_more_filter_container.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //header-----------------
                DashboardHeader(),

                //secciones de cards------
                SectionStaticsCard(),

                //seccion de activis
                Row(
                  spacing: 16,
                  children: [
                    Expanded(flex: 2, child: ActivityChartCard()),
                    Expanded(flex: 1, child: RecentActivities())
                  ],
                ),

                Row(
                  spacing: 16,
                  children: [
                    Expanded(child: EntityForCategoryContainer()),
                    Expanded(child: ServiceMoreFilterContainer())
                  ],
                )
              ],
            )),
      ),
    );
  }
}
