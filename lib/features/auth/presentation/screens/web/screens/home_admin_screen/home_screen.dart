import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/widgets/sidebar_footer_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/widgets/sidebar_header_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/widgets/sidebar_menu_item_widget.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Sidebar con el nuevo diseño
          Container(
            width: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2D5F4F), Color(0xFF1E4438)],
              ),
            ),
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
                          onTap: () => context.go('/dashboard/home'),
                        ),
                        const SizedBox(height: 8),
                        SidebarMenuItemWidget(
                          icon: Icons.show_chart_rounded,
                          title: 'Actividad Usuario',
                          isActive: location.startsWith(
                            "/dashboard/userActivity",
                          ),
                          onTap: () => context.go('/dashboard/userActivity'),
                        ),
                        const SizedBox(height: 8),
                        SidebarMenuItemWidget(
                          icon: Icons.people_alt_rounded,
                          title: 'Usuario',
                          isActive: location.startsWith('/dashboard/users'),
                          onTap: () => context.go('/dashboard/users'),
                        ),
                        const SizedBox(height: 8),
                        SidebarMenuItemWidget(
                          icon: Icons.business_rounded,
                          title: 'Entidades',
                          isActive: location.startsWith('/dashboard/entities'),
                          onTap: () => context.go('/dashboard/entities'),
                        ),
                        const SizedBox(height: 8),
                        SidebarMenuItemWidget(
                          icon: Icons.star_rounded,
                          title: 'Reseñas',
                          isActive: location.startsWith('/dashboard/reviews'),
                          onTap: () => context.go('/dashboard/reviews'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SidebarFooterWidget(),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: Container(
              color: const Color(0xFFF7F9FB),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
