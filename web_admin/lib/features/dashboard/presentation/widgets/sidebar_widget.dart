import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda_administracion/core/router/routes.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/sidebar_header_widget.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/sidebar_menu_item_widget.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/sidebar_footer_widget.dart';

class SidebarWidget extends ConsumerWidget {
  final String currentRoute;

  const SidebarWidget({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D5F4F), Color(0xFF1E4438)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SidebarHeaderWidget(),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SidebarMenuItemWidget(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    subtitle: 'Vista general',
                    isActive: currentRoute.startsWith('/dashboard/home'),
                    onTap: () => context.go('/dashboard/home'),
                  ),
                  const SizedBox(height: 8),
                  SidebarMenuItemWidget(
                    icon: Icons.show_chart_rounded,
                    title: 'Actividad Usuario',
                    isActive: currentRoute.startsWith(
                      "/dashboard/userActivity",
                    ),
                    onTap: () => context.go('/dashboard/userActivity'),
                  ),
                  const SizedBox(height: 8),
                  SidebarMenuItemWidget(
                    icon: Icons.people_alt_rounded,
                    title: 'Usuario',
                    isActive: currentRoute.startsWith('/dashboard/users'),
                    onTap: () => context.go('/dashboard/users'),
                  ),
                  const SizedBox(height: 8),
                  SidebarMenuItemWidget(
                    icon: Icons.business_rounded,
                    title: 'Entidades',
                    isActive: currentRoute.startsWith('/dashboard/entities'),
                    onTap: () => context.go('/dashboard/entities'),
                  ),
                  const SizedBox(height: 8),
                  SidebarMenuItemWidget(
                    icon: Icons.work_outline_rounded,
                    title: 'Servicios',
                    isActive: currentRoute.startsWith('/dashboard/services'),
                    onTap: () => context.go('/dashboard/services'),
                  ),
                ],
              ),
            ),
          ),
          const SidebarFooterWidget(),
        ],
      ),
    );
  }
}
