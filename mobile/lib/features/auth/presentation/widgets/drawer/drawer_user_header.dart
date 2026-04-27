import 'package:flutter/material.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class DrawerUserHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String origin;
  final String destination;
  final String age;

  const DrawerUserHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.origin,
    required this.destination,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Header con gradiente
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.75),
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
                userName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userEmail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),

        // Información del usuario
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.flight_takeoff_rounded,
                label: l10n.originLabel,
                value: origin,
              ),
              const SizedBox(height: 8),
              _InfoTile(
                icon: Icons.flight_land_rounded,
                label: l10n.destinationLabel,
                value: destination,
              ),
              const SizedBox(height: 8),
              _InfoTile(
                icon: Icons.cake_rounded,
                label: l10n.age,
                value: age,
              ),
            ],
          ),
        ),
      ],
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
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
