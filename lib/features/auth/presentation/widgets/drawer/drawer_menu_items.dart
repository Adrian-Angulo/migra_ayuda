import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerMenuItems extends ConsumerWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  const DrawerMenuItems({
    super.key,
    required this.onEditProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(),
        ),

        // Opciones del menú
        _DrawerOption(
          icon: Icons.edit_outlined,
          label: 'Editar Perfil',
          onTap: onEditProfile,
        ),

        const Spacer(),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),

        _DrawerOption(
          icon: Icons.logout_rounded,
          label: 'Cerrar Sesión',
          color: Colors.redAccent,
          onTap: onLogout,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DrawerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_outlined),
      horizontalTitleGap: 4,
      onTap: onTap,
    );
  }
}
