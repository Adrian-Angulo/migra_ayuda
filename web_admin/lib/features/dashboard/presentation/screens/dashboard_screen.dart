import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F7F6),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bienvenido de nuevo al panel de control de MigraAyuda.\nAquí tienes el resumen del impacto hoy.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 28),
            _StatsRow(),
            const SizedBox(height: 32),
            _RecentComments(),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<_StatData> stats = const [
    _StatData(label: 'TOTAL USUARIOS', value: '248', icon: Icons.person_outline),
    _StatData(label: 'ENTIDADES', value: '64', icon: Icons.business_outlined),
    _StatData(label: 'SERVICIOS ACTIVOS', value: '142', icon: Icons.volunteer_activism_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map((s) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _StatCard(data: s),
                ),
              ))
          .toList(),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  const _StatData({required this.label, required this.value, required this.icon});
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: const Color(0xFF4A8C8C), size: 28),
          const SizedBox(height: 12),
          Text(
            data.label,
            style: const TextStyle(fontSize: 11, letterSpacing: 1.1, color: Colors.black45),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _RecentComments extends StatelessWidget {
  final List<_CommentData> comments = const [
    _CommentData(
      name: 'Claudia Diaz',
      country: 'Venezuela',
      rating: 4.5,
      time: '2 MIN AGO',
      text: 'Buen servicio. La atención en el centro de recepción fue muy rápida y clara con los requisitos para el permiso temporal.',
    ),
    _CommentData(
      name: 'Elena Rodriguez',
      country: 'Colombia',
      rating: 4.5,
      time: '15 MIN AGO',
      text: 'Refugee Assistance Network updated their contact protocols and added 3 new emergency phone lines for late-night assistance.',
    ),
    _CommentData(
      name: 'Marco Aurelio',
      country: 'Venezuela',
      rating: 4.5,
      time: '1 HOUR AGO',
      text: 'Excelente servicio. Me han dado kits de higiene.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Comentarios Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Actividad y retroalimentación de la red en tiempo real', style: TextStyle(color: Colors.black45, fontSize: 13)),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ver todo', style: TextStyle(color: Color(0xFF4A8C8C))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...comments.map((c) => _CommentTile(data: c)).toList(),
        ],
      ),
    );
  }
}

class _CommentData {
  final String name;
  final String country;
  final double rating;
  final String time;
  final String text;
  const _CommentData({
    required this.name,
    required this.country,
    required this.rating,
    required this.time,
    required this.text,
  });
}

class _CommentTile extends StatelessWidget {
  final _CommentData data;
  const _CommentTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFE8EEF0),
            child: const Icon(Icons.person, color: Colors.grey, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(data.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(data.country, style: const TextStyle(fontSize: 11, color: Color(0xFF4A8C8C))),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(' ${data.rating}/5', style: const TextStyle(fontSize: 12, color: Colors.amber)),
                    const Spacer(),
                    Text(data.time, style: const TextStyle(fontSize: 11, color: Colors.black38)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(data.text, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
