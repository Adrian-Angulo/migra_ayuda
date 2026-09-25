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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Divider(color: Color(0xFFF1F5F9)),
        ),

        // Opciones del menú
        _DrawerOption(
          icon: Icons.edit_note_rounded,
          iconColor: const Color(0xFF00897B),
          label: 'Editar Perfil',
          onTap: onEditProfile,
        ),

        const Spacer(),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: Color(0xFFF1F5F9)),
        ),

        _DrawerOption(
          icon: Icons.logout_rounded,
          iconColor: const Color(0xFFE53935),
          label: 'Cerrar Sesión',
          labelColor: const Color(0xFFE53935),
          onTap: onLogout,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DrawerOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _DrawerOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: labelColor ?? const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: Color(0xFF94A3B8),
        ),
        horizontalTitleGap: 12,
        onTap: onTap,
      ),
    );
  }
}
