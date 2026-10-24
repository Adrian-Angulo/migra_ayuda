import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/widgets/sidebar_footer_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/widgets/sidebar_header_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/widgets/sidebar_menu_item_widget.dart';


class SidebarWidget extends StatelessWidget {
  final double width;

  const SidebarWidget({
    super.key,
    this.width = 250,
  });

  void _onNavigate(BuildContext context, String path) {

    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D5F4F), Color(0xFF1E4438)],
        ),
      ),
      child: SafeArea(
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
                      isActive: location.startsWith('/dashboard/home'),
                      onTap: () => _onNavigate(context, '/dashboard/home'),
                    ),
                    const SizedBox(height: 8),
                    SidebarMenuItemWidget(
                      icon: Icons.show_chart_rounded,
                      title: 'Actividad Usuario',
                      isActive: location.startsWith('/dashboard/userActivity'),
                      onTap: () => _onNavigate(context, '/dashboard/userActivity'),
                    ),
                    const SizedBox(height: 8),
                    SidebarMenuItemWidget(
                      icon: Icons.people_alt_rounded,
                      title: 'Usuario',
                      isActive: location.startsWith('/dashboard/users'),
                      onTap: () => _onNavigate(context, '/dashboard/users'),
                    ),
                    const SizedBox(height: 8),
                    SidebarMenuItemWidget(
                      icon: Icons.business_rounded,
                      title: 'Organizaciones',
                      isActive: location.startsWith('/dashboard/entities'),
                      onTap: () => _onNavigate(context, '/dashboard/entities'),
                    ),
                    const SizedBox(height: 8),
                    SidebarMenuItemWidget(
                      icon: Icons.star_rounded,
                      title: 'Reseñas',
                      isActive: location.startsWith('/dashboard/reviews'),
                      onTap: () => _onNavigate(context, '/dashboard/reviews'),
                    ),
                  ],
                ),
              ),
            ),
            const SidebarFooterWidget(),
          ],
        ),
      ),
    );
  }
}
