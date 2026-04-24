import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    "Adrian Angulo",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "adrianangulo1080@gmail.com",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            // User info
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.flight_takeoff_rounded,
                    label: "País de origen",
                    value: "México",
                  ),
                  SizedBox(height: 8),
                  _InfoTile(
                    icon: Icons.flight_land_rounded,
                    label: "País de destino",
                    value: "España",
                  ),
                  SizedBox(height: 8),
                  _InfoTile(
                    icon: Icons.cake_rounded,
                    label: "Edad",
                    value: "28 años",
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(),
            ),

            // Options
            _DrawerOption(
              icon: Icons.edit_outlined,
              label: "Editar perfil",
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerOption(
              icon: Icons.language_rounded,
              label: "Cambiar idioma",
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),

            _DrawerOption(
              icon: Icons.logout_rounded,
              label: "Salir",
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
      trailing: Icon(Icons.keyboard_arrow_right_outlined),
      horizontalTitleGap: 4,
      onTap: onTap,
    );
  }
}
