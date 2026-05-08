import 'package:flutter/material.dart';

class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            const SizedBox(height: 32),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),

            // Activities List
            _buildActivitiesList(),
            const SizedBox(height: 24),

            // Pagination
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad de Usuarios',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E4438),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Registro de auditoría del sistema',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por usuario o acción...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey[600]),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAllActivities() {
    // Mock data - Simulando más datos para la paginación
    return [
      {
        'user': 'Juan Pérez',
        'action': 'Inició sesión',
        'date': 'Hoy, 10:30 AM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'María García',
        'action': 'Actualizó perfil',
        'date': 'Hoy, 09:15 AM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'Carlos López',
        'action': 'Cerró sesión',
        'date': 'Ayer, 18:45 PM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'Ana Martínez',
        'action': 'Creó nueva entidad',
        'date': 'Ayer, 16:20 PM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'Pedro Sánchez',
        'action': 'Eliminó servicio',
        'date': 'Ayer, 14:10 PM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'Laura Rodríguez',
        'action': 'Modificó configuración',
        'date': '2 días atrás, 11:30 AM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'Roberto Díaz',
        'action': 'Inició sesión',
        'date': '2 días atrás, 10:00 AM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'Sofia Torres',
        'action': 'Actualizó servicio',
        'date': '3 días atrás, 15:30 PM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'Miguel Ángel',
        'action': 'Cerró sesión',
        'date': '3 días atrás, 12:00 PM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'Carmen Ruiz',
        'action': 'Creó usuario',
        'date': '4 días atrás, 09:45 AM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'Fernando López',
        'action': 'Eliminó entidad',
        'date': '4 días atrás, 08:20 AM',
        'color': const Color(0xFF2D5F4F),
      },
      {
        'user': 'Isabel Moreno',
        'action': 'Modificó permisos',
        'date': '5 días atrás, 17:10 PM',
        'color': const Color(0xFF2D5F4F),
      },
    ];
  }

  Widget _buildActivitiesList() {
    final allActivities = _getAllActivities();

    // Calcular el índice de inicio y fin para la página actual
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      allActivities.length,
    );

    // Obtener solo las actividades de la página actual
    final currentActivities = allActivities.sublist(startIndex, endIndex);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentActivities.length,
      itemBuilder: (context, index) {
        final activity = currentActivities[index];
        return _buildActivityCard(
          user: activity['user'] as String,
          action: activity['action'] as String,
          date: activity['date'] as String,
          color: activity['color'] as Color,
        );
      },
    );
  }

  Widget _buildPagination() {
    final allActivities = _getAllActivities();
    final totalPages = (allActivities.length / _itemsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón anterior
        IconButton(
          onPressed: _currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: _currentPage > 1
                ? const Color(0xFF2D5F4F)
                : Colors.grey[300],
            foregroundColor: _currentPage > 1 ? Colors.white : Colors.grey[500],
          ),
        ),
        const SizedBox(width: 16),

        // Números de página
        ...List.generate(totalPages, (index) {
          final pageNumber = index + 1;
          final isCurrentPage = pageNumber == _currentPage;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentPage = pageNumber;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCurrentPage
                      ? const Color(0xFF2D5F4F)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$pageNumber',
                    style: TextStyle(
                      color: isCurrentPage ? Colors.white : Colors.grey[700],
                      fontWeight: isCurrentPage
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(width: 16),

        // Botón siguiente
        IconButton(
          onPressed: _currentPage < totalPages
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_right),
          style: IconButton.styleFrom(
            backgroundColor: _currentPage < totalPages
                ? const Color(0xFF2D5F4F)
                : Colors.grey[300],
            foregroundColor: _currentPage < totalPages
                ? Colors.white
                : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required String user,
    required String action,
    required String date,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with user initial
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Text(
              user[0].toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User info and action
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E4438),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // Date
          Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
