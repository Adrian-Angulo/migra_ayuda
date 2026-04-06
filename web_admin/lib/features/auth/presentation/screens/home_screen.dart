import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: Material(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 32),
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _SidebarItem(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        isActive: location.startsWith('/dashboard/home'),
                        onTap: () => context.go('/dashboard/home'),
                      ),
                      _SidebarItem(
                        icon: Icons.people_outline,
                        label: 'Usuarios',
                        isActive: location.startsWith('/dashboard/users'),
                        onTap: () => context.go('/dashboard/users'),
                      ),
                      _SidebarItem(
                        icon: Icons.grid_view_outlined,
                        label: 'Servicios',
                        isActive: location.startsWith('/dashboard/services'),
                        onTap: () => context.go('/dashboard/services'),
                      ),
                      _SidebarItem(
                        icon: Icons.business_outlined,
                        label: 'Entidades',
                        isActive: location.startsWith('/dashboard/entities'),
                        onTap: () => context.go('/dashboard/entities'),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'usuario@correo.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFAAAAAA),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            // cerrar sesion
                          },
                          icon: const Icon(
                            Icons.logout,
                            size: 14,
                            color: Color(0xFFAAAAAA),
                          ),
                          label: const Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(width: 1, color: const Color(0xFFEEEEEE)),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF1A1A1A) : const Color(0xFFAAAAAA);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  left: BorderSide(color: Color(0xFF1A1A1A), width: 2),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
