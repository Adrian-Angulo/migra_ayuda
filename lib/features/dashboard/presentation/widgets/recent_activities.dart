import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/utils/format/time_formatter.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';
import 'package:migra_ayuda/features/dashboard/presentation/providers/dashboard_providers.dart';

class RecentActivities extends ConsumerWidget {
  const RecentActivities({super.key});

  String? _getMetadatos(AuditEntity audit) {
    if (audit.metadata != null && audit.metadata!.isNotEmpty) {
      return audit.metadata?.entries.map((e) => '${e.value}').join(', ');
    } else {
      return audit.correo;
    }
  }

  String _mapAccion(String accion) {
    final Map<String, String> accionMap = {
      'filtrar': 'Filtro aplicado',
      'iniciar sesión': 'Nuevo ingreso',
      'ver entidad': 'Entidad selecionada',
      'como llegar': 'ruta solicitada',
      'cierre de session': 'Cierre de sesión',
    };

    return accionMap[accion.toLowerCase()] ?? accion;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audirRecentState = ref.watch(recentActivityProvider);
    return FadeInUp(
      child: Container(
        decoration: ContainerDecorationBorder.decorationBox(),
        height: 450,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Actividades recientes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Ver todas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5F4F),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: audirRecentState.when(
                      data: (list) {
                        return ListView.separated(
                            itemBuilder: (context, index) {
                              final AuditEntity audit = list[index];
                              return ActivityItem(
                                  icon: Icons.person_outline,
                                  title: _mapAccion(audit.accion),
                                  subtitle: _getMetadatos(audit)!,
                                  time:
                                      TimeFormatter.formatDate(audit.createdAt));
                            },
                            separatorBuilder: (context, index) => const SizedBox(
                                  height: 5,
                                ),
                            itemCount: list.length);
                      },
                      error: (error, stackTrace) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Ha ocurrido un error:'),
                                Text('Error: ${error.toString()}'),
                              ],
                            ),
                          ),
                      loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ))),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const ActivityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
