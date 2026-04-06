import 'package:flutter/material.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/stat_card_widget.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/comment_card_widget.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/section_header_widget.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bienvenido de nuevo al panel de control de MigraAyuda.\nAquí tienes el resumen del impacto hoy.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: StatCardWidget(
                  icon: Icons.people_outline_rounded,
                  iconColor: const Color(0xFF2D5F4F),
                  iconBackgroundColor: const Color(0xFF2D5F4F).withOpacity(0.1),
                  label: 'Total Usuarios',
                  value: '248',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCardWidget(
                  icon: Icons.business_outlined,
                  iconColor: const Color(0xFF4F7FD4),
                  iconBackgroundColor: const Color(0xFF4F7FD4).withOpacity(0.1),
                  label: 'Entidades',
                  value: '64',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCardWidget(
                  icon: Icons.favorite_outline_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBackgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                  label: 'Servicios Activos',
                  value: '142',
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Comentarios Recientes
          SectionHeaderWidget(
            title: 'Comentarios Recientes',
            subtitle: 'Actividad y retroalimentación de la red en tiempo real',
            actionText: 'Ver todo',
            onActionTap: () {
              // TODO: Navegar a todos los comentarios
            },
          ),
          const SizedBox(height: 24),

          // Lista de comentarios
          const CommentCardWidget(
            userName: 'Claudia díaz',
            userCountry: 'Venezuela',
            rating: 4.5,
            comment:
                'Buen servicio. La atención en el centro de recepción fue muy rápida y clara con los requisitos para el permiso temporal.',
            timeAgo: '2 min ago',
          ),
          const CommentCardWidget(
            userName: 'Elena Rodriguez',
            userCountry: 'Colombia',
            rating: 4.5,
            comment:
                'Refugee Assistance Network updated their contact protocols and added 3 new emergency phone lines for late-night assistance.',
            timeAgo: '15 min ago',
          ),
          const CommentCardWidget(
            userName: 'Marco Aurelio',
            userCountry: 'Venezuela',
            rating: 4.5,
            comment: 'Excelente servicio. Me han dado kits de higiene.',
            timeAgo: '1 hour ago',
          ),
        ],
      ),
    );
  }
}
