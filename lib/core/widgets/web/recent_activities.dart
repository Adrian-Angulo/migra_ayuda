import 'package:flutter/material.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: Card(
        elevation: 0,
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
                      fontSize: 16,
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver todas'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const ActivityItem(
                icon: Icons.person_outline,
                title: 'Nuevo usuario registrado',
                subtitle: 'juan.perez@email.com',
                time: 'Hace 5 minutos',
              ),

              const ActivityItem(
                icon: Icons.business,
                title: 'Nueva entidad agregada',
                subtitle: 'Centro de Salud Central',
                time: 'Hace 1 hora',
              ),

              const ActivityItem(
                icon: Icons.comment_outlined,
                title: 'Nuevo comentario',
                subtitle: 'Muy útil la información',
                time: 'Hace 2 horas',
              ),

              const ActivityItem(
                icon: Icons.filter_alt_outlined,
                title: 'Ruta solicitada',
                subtitle: 'Hacia: Centro de Empleo',
                time: 'Hace 3 horas',
              ),
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.blue,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Text(
            time,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}