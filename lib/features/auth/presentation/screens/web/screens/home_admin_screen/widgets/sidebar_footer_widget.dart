import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';


class SidebarFooterWidget extends ConsumerWidget {
  const SidebarFooterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Administrador',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authState.when(
              data: (user) => user?.email ?? 'Sin correo',
              loading: () => 'Cargando...',
              error: (_, __) => 'Error al cargar',
            ),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 16),
          // Botón de logout (opcional, puede ser un menú)
          TextButton.icon(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
            icon: Icon(
              Icons.logout_rounded,
              size: 16,
              color: Colors.white.withOpacity(0.7),
            ),
            label: Text(
              'Cerrar sesión',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
