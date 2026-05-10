import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/delete_entity_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_detail_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/delete_confirmation_dialog.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/edit_entity_modal.dart';

class EntityDetailScreen extends ConsumerStatefulWidget {
  final String entityId;

  const EntityDetailScreen({super.key, required this.entityId});

  @override
  ConsumerState<EntityDetailScreen> createState() => _EntityDetailScreenState();
}

class _EntityDetailScreenState extends ConsumerState<EntityDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(entityDetailNotifierProvider.notifier)
          .setEntityId(widget.entityId);
      ref.read(entityDetailNotifierProvider.notifier).recargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncEntity = ref.watch(entityDetailNotifierProvider);

    // Escuchar cambios en el estado de eliminación
    ref.listen<AsyncValue<void>>(deleteEntityNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (_) {
          // Éxito - mostrar mensaje y volver al listado
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Entidad eliminada exitosamente'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );

          context.go('/dashboard/entities');
        },
        loading: () {},
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error: ${error.toString()}')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: asyncEntity.when(
        data: (entity) => CustomScrollView(
          slivers: [
            // Hero header con imagen de fondo
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: const Color(0xFF1B4332),
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: IconButton(
                    onPressed: () => context.go('/dashboard/entities'),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              actions: [
                // Botón de eliminar
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.red.shade400.withValues(alpha: 0.9),
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => DeleteConfirmationDialog(
                            entityName: entity.name,
                            onConfirm: () {
                              ref
                                  .read(deleteEntityNotifierProvider.notifier)
                                  .eliminar(entity.id);
                            },
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                // Botón de editar
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    child: IconButton(
                      onPressed: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => EditEntityModal(entity: entity),
                        );

                        // Si se editó exitosamente, recargar los datos
                        if (result == true && context.mounted) {
                          ref
                              .read(entityDetailNotifierProvider.notifier)
                              .recargar();
                        }
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen de fondo
                    entity.imageUrl.isEmpty
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.business_outlined,
                                size: 80,
                                color: Colors.white24,
                              ),
                            ),
                          )
                        : Image.network(
                            entity.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF1B4332),
                                        Color(0xFF2D6A4F),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 80,
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                          ),
                    // Gradiente sobre la imagen
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                    // Info sobre la imagen
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF52B788),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  entity.services.isNotEmpty
                                      ? entity.services.first
                                      : 'Comida',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Color(0xFFFBBF24),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '4.4  (4k)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            entity.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                              shadows: [
                                Shadow(color: Colors.black45, blurRadius: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido principal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats rápidos
                    const SizedBox(height: 28),

                    // Descripción
                    _buildSectionTitle('Descripción'),
                    const SizedBox(height: 12),
                    Text(
                      entity.description.isEmpty
                          ? 'Fundación Kiwanis se dedica a erradicar la inseguridad alimentaria a través de programas de nutrición sostenible. Operamos como un puente entre la abundancia agrícola y las comunidades que más lo necesitan, asegurando que cada familia tenga acceso a alimentos frescos, orgánicos y nutritivos.'
                          : entity.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4B5563),
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Información de contacto
                    _buildSectionTitle('Información de contacto'),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildContactTile(
                            icon: Icons.location_on_outlined,
                            iconColor: const Color(0xFF059669),
                            iconBg: const Color(0xFFD1FAE5),
                            label: 'Dirección',
                            value: entity.address.isEmpty
                                ? 'Calle 45 #12-89, Sector Histórico'
                                : entity.address,
                            isFirst: true,
                          ),
                          _buildDivider(),
                          _buildContactTile(
                            icon: Icons.phone_outlined,
                            iconColor: const Color(0xFF2563EB),
                            iconBg: const Color(0xFFDBEAFE),
                            label: 'Teléfono',
                            value: entity.phone.isEmpty
                                ? '+57 (310) 456-7890'
                                : entity.phone,
                          ),
                          _buildDivider(),
                          _buildContactTile(
                            icon: Icons.email_outlined,
                            iconColor: const Color(0xFF7C3AED),
                            iconBg: const Color(0xFFEDE9FE),
                            label: 'Email',
                            value: 'contacto@kiwanisfoundation.org',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Horarios
                    _buildSectionTitle('Horarios de atención'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildScheduleRow(
                            'Lunes - Viernes',
                            '08:00 - 17:00',
                            true,
                          ),
                          const SizedBox(height: 12),
                          _buildScheduleRow('Sábado', '09:00 - 13:00', true),
                          const SizedBox(height: 12),
                          _buildScheduleRow('Domingo', 'Cerrado', false),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Mapa real con ubicación
                    _buildSectionTitle('Ubicación'),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 220,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(
                              entity.localitation.latitude,
                              entity.localitation.longitude,
                            ),
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.migraayuda.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                    entity.localitation.latitude,
                                    entity.localitation.longitude,
                                  ),
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Color(0xFF059669),
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Comentarios
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Comentarios'),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '5 reseñas',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildCommentCard(
                      initials: 'MA',
                      name: 'María Arboleda',
                      timeAgo: 'Hace 2 días',
                      rating: 5,
                      comment:
                          'Excelente labor. La transparencia con la que manejan los recursos y la calidad de los alimentos que entregan es realmente inspiradora para toda la comunidad.',
                      avatarColor: const Color(0xFFD1FAE5),
                      initialsColor: const Color(0xFF059669),
                    ),

                    const SizedBox(height: 12),

                    _buildCommentCard(
                      initials: 'JC',
                      name: 'Juan Carlos',
                      timeAgo: 'Hace 1 semana',
                      rating: 4,
                      comment:
                          'Un gran equipo de voluntarios. Se nota el compromiso humano en cada entrega. Sería ideal ampliar los horarios de atención los fines de semana.',
                      avatarColor: const Color(0xFFDBEAFE),
                      initialsColor: const Color(0xFF1E88E5),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2D5F4F)),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Oops! Algo salió mal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go('/dashboard/entities'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D5F4F),
                        side: const BorderSide(
                          color: Color(0xFF2D5F4F),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(entityDetailNotifierProvider.notifier)
                            .recargar();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5F4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF059669)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 76,
      endIndent: 20,
      color: Color(0xFFF3F4F6),
    );
  }

  Widget _buildScheduleRow(String day, String hours, bool isOpen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOpen
                    ? const Color(0xFF10B981)
                    : const Color(0xFFD1D5DB),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              day,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            ),
          ],
        ),
        Text(
          hours,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isOpen ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentCard({
    required String initials,
    required String name,
    required String timeAgo,
    required int rating,
    required String comment,
    required Color avatarColor,
    required Color initialsColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: initialsColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 15,
                      color: index < rating
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  comment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
