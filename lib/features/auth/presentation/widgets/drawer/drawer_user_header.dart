import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';

class DrawerUserHeader extends ConsumerWidget {
  const DrawerUserHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asynUser = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return asynUser.when(
      error: (error, stackTrace) => Text('error ${error.toString()}'),
      loading: () => const CircularProgressIndicator(),
      data: (user) {
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
                    user?.name ?? 'Sin datos',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? 'Sin datos',
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
                    label: 'Origen',
                    value: user?.originCountry ?? 'Sin datos',
                  ),
                  const SizedBox(height: 8),
                  _InfoTile(
                    icon: Icons.flight_land_rounded,
                    label: 'Destino',
                    value: user?.destinationCountry ?? 'Sin datos',
                  ),
                  const SizedBox(height: 8),
                  _InfoTile(
                    icon: Icons.cake_rounded,
                    label: 'Edad',
                    value: user?.age ?? 'Sin datos',
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
