import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda_administracion/features/auth/presentation/providers/auth_notifier.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(location: location),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String location;

  const _Sidebar({required this.location});

  static const _navItems = [
    (icon: Icons.dashboard_rounded, label: 'Home', route: '/dashboard/home'),
    (
      icon: Icons.people_alt_rounded,
      label: 'Usuarios',
      route: '/dashboard/users',
    ),
    (
      icon: Icons.miscellaneous_services_rounded,
      label: 'Servicios',
      route: '/dashboard/services',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Material(
        color: const Color(0xFF1A1D2E),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SidebarHeader(),
            const SizedBox(height: 8),
            /* ..._navItems.map(
              (item) => _SidebarItem(
                icon: item.icon,
                label: item.label,
                isActive: location.startsWith(item.route),
                onTap: () => context.go(item.route),
              ),
            ), */
            Expanded(
              child: ListView.builder(
                itemCount: _navItems.length,
                itemBuilder: (context, index) {
                  final item = _navItems[index];
                  return _SidebarItem(
                    icon: item.icon,
                    label: item.label,
                    isActive: location.startsWith(item.route),
                    onTap: () => context.go(item.route),
                  );
                },
              ),
            ),
            const Spacer(),
            _SidebarFooter(),
          ],
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.public, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'MigraAyuda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarFooter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade700,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrador',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Admin',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            child: const Text("Cerrar sesion"),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: Icon(
            icon,
            size: 20,
            color: isActive ? Colors.blue.shade300 : Colors.white38,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue.shade300 : Colors.white54,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
