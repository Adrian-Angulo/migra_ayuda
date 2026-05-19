import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity_entity.dart';
import 'package:migra_ayuda/features/userActivity/presentation/providers/get_all_activity_notifier.dart';
import 'package:intl/intl.dart';

class UserActivityScreen extends ConsumerStatefulWidget {
  const UserActivityScreen({super.key});

  @override
  ConsumerState<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends ConsumerState<UserActivityScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(getAllActivityNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: activitiesAsync.when(
        data: (activities) => _buildContent(activities),
        loading: () => _buildLoading(),
        error: (error, stack) => _buildError(error.toString()),
      ),
    );
  }

  Widget _buildContent(List<UserActivityEntity> activities) {
    final filteredActivities = activities.where((activity) {
      final searchLower = _searchQuery.toLowerCase();
      return activity.idUser.toLowerCase().contains(searchLower) ||
          activity.accion.toLowerCase().contains(searchLower);
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildStatsCards(filteredActivities.length),
            const SizedBox(height: 32),
            _buildTableSection(filteredActivities),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(getAllActivityNotifierProvider.notifier).refresh();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Auditoría',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Consulta y monitorea las acciones realizadas en la plataforma.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por usuario, acción o recurso...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildFilterButton('Fecha inicial', '01/05/2024', Icons.calendar_today),
        const SizedBox(width: 12),
        _buildFilterButton('Fecha final', '18/05/2024', Icons.calendar_today),
        const SizedBox(width: 12),
        _buildFilterButton('Módulo', 'Todos', Icons.arrow_drop_down),
        const SizedBox(width: 12),
        _buildFilterButton('Acción', 'Todas', Icons.arrow_drop_down),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(getAllActivityNotifierProvider.notifier).refresh();
          },
          icon: const Icon(Icons.filter_alt, size: 18),
          label: const Text('Filtrar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _searchQuery = '';
              _currentPage = 1;
            });
          },
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Limpiar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(icon, size: 16, color: Colors.grey[600]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(int totalActivities) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF3B82F6),
          iconBg: const Color(0xFFDCEEFF),
          title: totalActivities.toString(),
          subtitle: 'Total acciones',
          description: 'En el período seleccionado',
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.people_outline,
          iconColor: const Color(0xFF10B981),
          iconBg: const Color(0xFFD1FAE5),
          title: '156',
          subtitle: 'Usuarios activos',
          description: 'Con acciones registradas',
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFFF59E0B),
          iconBg: const Color(0xFFFEF3C7),
          title: '12',
          subtitle: 'Acciones críticas',
          description: 'Requieren revisión',
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF8B5CF6),
          iconBg: const Color(0xFFEDE9FE),
          title: '98.5%',
          subtitle: 'Acciones exitosas',
          description: 'Tasa de éxito',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection(List<UserActivityEntity> activities) {
    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Text(
            'No hay actividades registradas',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, activities.length);
    final currentActivities = activities.sublist(startIndex, endIndex);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Registro de auditoría',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Exportar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildTable(currentActivities),
          _buildTableFooter(activities.length),
        ],
      ),
    );
  }

  Widget _buildTable(List<UserActivityEntity> activities) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey[200]!),
      ),
      children: [
        _buildTableHeader(),
        ...activities.map((activity) => _buildTableRow(activity)),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[50]),
      children: [
        _buildHeaderCell('Fecha y hora'),
        _buildHeaderCell('Usuario'),
        _buildHeaderCell('Acción'),
        _buildHeaderCell('Pais'),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  TableRow _buildTableRow(UserActivityEntity activity) {
    final color = _getColorForUser(activity.idUser);

    return TableRow(
      children: [
        _buildTableCell(
          child: Text(
            _formatDateTime(activity.createdAt),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        _buildTableCell(
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Text(
                  activity.idUser.isNotEmpty
                      ? activity.nombre[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.nombre,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      activity.correo,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildTableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    activity.accion,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildTableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              activity.pais,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: child,
    );
  }

  Widget _buildTableFooter(int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final startItem = (_currentPage - 1) * _itemsPerPage + 1;
    final endItem = (startItem + _itemsPerPage - 1).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrando $startItem a $endItem de $totalItems registros',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Anterior', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              ...List.generate(
                totalPages.clamp(0, 5),
                (index) {
                  final page = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => setState(() => _currentPage = page),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _currentPage == page
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _currentPage == page
                                ? const Color(0xFF6366F1)
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$page',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _currentPage == page
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (totalPages > 5) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('...', style: TextStyle(color: Colors.grey[600])),
                ),
                InkWell(
                  onTap: () => setState(() => _currentPage = totalPages),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        '$totalPages',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _currentPage < totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Siguiente', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  Color _getColorForUser(String userId) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    final hash = userId.hashCode.abs();
    return colors[hash % colors.length];
  }
}
