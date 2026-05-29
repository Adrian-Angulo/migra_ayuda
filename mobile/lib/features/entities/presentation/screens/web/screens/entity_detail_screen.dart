import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/widgets/badge_widget.dart';
import 'package:migra_ayuda/core/widgets/divider_widget.dart';
import 'package:migra_ayuda/core/widgets/placeholder_image.dart';
import 'package:migra_ayuda/core/widgets/web/map_web.dart';
import 'package:migra_ayuda/core/widgets/web/section_title.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/widgets/comment_card_widget.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/delete_entity_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_detail_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/delete_confirmation_dialog.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/edit_entity_modal.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/rating_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/service_chip.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RECOMENDACIONES:
//
// 1. SEPARAR WIDGETS EN ARCHIVOS PROPIOS
//    Los widgets privados (_buildCommentCard, _buildContactTile, etc.) son
//    suficientemente complejos para vivir en sus propios archivos dentro de
//    un directorio `widgets/`. Esto mejora la legibilidad y la reutilización.
//
// 2. EXTRAER CONSTANTES DE COLOR Y ESTILO
//    Los colores hardcodeados (Color(0xFF1B4332), Color(0xFF059669), etc.)
//    deberían centralizarse en un archivo `app_colors.dart` o en el ThemeData
//    de la app. Así un cambio de paleta no requiere tocar cada widget.
//
// 3. DATOS FICTICIOS EN PRODUCCIÓN
//    La sección de comentarios usa datos estáticos (María Arboleda, 5 reseñas).
//    Conectar esto a un provider real evita confusión y prepara la pantalla
//    para escalar.
//
// 4. CAMPOS SIN DATOS REALES
//    Email y horario muestran "no disponible" porque el modelo Entity no los
//    expone aún. Considera añadir esos campos al modelo o eliminar las filas
//    hasta que estén disponibles.
//
// 5. ACCESIBILIDAD
//    Los IconButton dentro de CircleAvatar carecen de `tooltip`. Añadir
//    tooltips mejora la experiencia con lectores de pantalla.
//
// 6. MANEJO DE ERRORES EN IMÁGENES
//    El errorBuilder del Image.network repite el mismo gradiente del estado
//    vacío. Extraerlo a un widget `_EntityImagePlaceholder` elimina la
//    duplicación.
//
// 7. INTERACTIVIDAD DEL MAPA
//    El mapa tiene `InteractiveFlag.none`. Si la intención es solo mostrar
//    la ubicación, considera reemplazarlo por una imagen estática de mapa
//    (p. ej. Static Maps API) para reducir dependencias y peso de la pantalla.
//
// 8. UNUSED METHODS
//    `_buildStatChip` y `_buildScheduleRow` están definidos pero nunca se
//    usan en el árbol de widgets. Eliminarlos o conectarlos evita dead code.
// ─────────────────────────────────────────────────────────────────────────────

class EntityDetailScreen extends ConsumerStatefulWidget {
  final String entityId;

  const EntityDetailScreen({super.key, required this.entityId});

  @override
  ConsumerState<EntityDetailScreen> createState() => _EntityDetailScreenState();
}

class _EntityDetailScreenState extends ConsumerState<EntityDetailScreen> {
  // ── Colores de la pantalla ──────────────────────────────────────────────────
  static const _primaryGreen = Color(0xFF1B4332);
  static const _accentGreen = Color(0xFF2D6A4F);
  static const _actionGreen = Color(0xFF059669);
  static const _lightGreen = Color(0xFFD1FAE5);
  static const _textDark = Color(0xFF111827);
  static const _textMid = Color(0xFF4B5563);
  static const _textLight = Color(0xFF9CA3AF);
  static const _bgPage = Color(0xFFF8FAFC);
  static const _dividerColor = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(entityDetailNotifierProvider.notifier);
      notifier.setEntityId(widget.entityId);
      notifier.recargar();
    });
  }

  // ── Listeners ──────────────────────────────────────────────────────────────

  void _onDeleteStateChange(AsyncValue<void>? previous, AsyncValue<void> next) {
    next.when(
      data: (_) {
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
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  // ── Acciones ───────────────────────────────────────────────────────────────

  void _showDeleteDialog(String entityId, String entityName) {
    showDialog(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        entityName: entityName,
        onConfirm: () =>
            ref.read(deleteEntityNotifierProvider.notifier).eliminar(entityId),
      ),
    );
  }

  Future<void> _showEditModal(dynamic entity) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => EditEntityModal(entity: entity),
    );
    if (updated == true && mounted) {
      ref.read(entityDetailNotifierProvider.notifier).recargar();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final asyncEntity = ref.watch(entityDetailNotifierProvider);

    ref.listen<AsyncValue<void>>(
      deleteEntityNotifierProvider,
      _onDeleteStateChange,
    );

    return Scaffold(
      backgroundColor: _bgPage,
      body: asyncEntity.when(
        data: (entity) => DetallesEntity(
          entity: entity,
        ),

        /* _EntityDetailBody(
          entity: entity,
          onDelete: () => _showDeleteDialog(entity.id, entity.name),
          onEdit: () => _showEditModal(entity),
          onBack: () => context.go('/dashboard/entities'),
          onRetry: () =>
              ref.read(entityDetailNotifierProvider.notifier).recargar(),
        ), */
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2D5F4F)),
        ),
        error: (error, _) => _ErrorView(
          error: error.toString(),
          onBack: () => context.go('/dashboard/entities'),
          onRetry: () =>
              ref.read(entityDetailNotifierProvider.notifier).recargar(),
        ),
      ),
    );
  }
}

class DetallesEntity extends StatelessWidget {
  final EntityEntity entity;
  const DetallesEntity({
    super.key,
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                _CircleIconButton(
                  tooltip: 'Volver',
                  onPressed: () => context.go('/dashboard/entities'),
                  icon: Icons.arrow_back_ios_new,
                ),
                const Spacer(),
                _CircleIconButton(
                  tooltip: 'Eliminar entidad',
                  onPressed: () {},
                  icon: Icons.delete_outline,
                  backgroundColor: Colors.red.shade400.withValues(alpha: 0.9),
                ),
                _CircleIconButton(
                  tooltip: 'Editar entidad',
                  onPressed: () {},
                  icon: Icons.edit_outlined,
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 16),

            // ── Contenido principal ─────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Columna izquierda: imagen + info ────────────────────────
                Expanded(
                  child: BadgeWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Image.network(
                            entity.imageUrl,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const PlaceholderImage(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nombre y rating
                              SectionTitle(entity.name),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  RatingWidget(rating: entity.averageRating),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${entity.totalReviews} reseñas)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                entity.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Servicios
                              const SectionTitle('Servicios', size: 16),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: entity.services
                                    .map((service) =>
                                        ServiceChip(service: service))
                                    .toList(),
                              ),
                              const SizedBox(height: 16),

                              const DividerWidget(),
                              const SizedBox(height: 12),

                              // Contacto
                              _ContactTile(
                                icon: Icons.location_on_outlined,
                                iconColor: const Color(0xFF059669),
                                iconBg: const Color(0xFFD1FAE5),
                                label: 'Dirección',
                                value: entity.address.isEmpty
                                    ? 'Dirección no disponible'
                                    : entity.address,
                              ),
                              const SizedBox(height: 8),
                              _ContactTile(
                                icon: Icons.phone_outlined,
                                iconColor: const Color(0xFF2563EB),
                                iconBg: const Color(0xFFDBEAFE),
                                label: 'Teléfono',
                                value: entity.phone.isEmpty
                                    ? 'Teléfono no disponible'
                                    : entity.phone,
                              ),
                              const SizedBox(height: 8),
                              const _ContactTile(
                                icon: Icons.email_outlined,
                                iconColor: Color(0xFF7C3AED),
                                iconBg: Color(0xFFEDE9FE),
                                label: 'Correo electrónico',
                                value: 'Email no disponible',
                              ),
                              const SizedBox(height: 8),
                              const _ContactTile(
                                icon: Icons.schedule_outlined,
                                iconColor: Color(0xFFD97706),
                                iconBg: Color(0xFFFEF3C7),
                                label: 'Horario de atención',
                                value: 'Horario no disponible',
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // ── Columna derecha: mapa + comentarios ─────────────────────
                Expanded(
                  child: Column(
                    children: [
                      // Mapa
                      BadgeWidget(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionTitle('Ubicación'),
                              const SizedBox(height: 12),
                              MapWeb(
                                latitude: entity.localitation.latitude,
                                longitude: entity.localitation.longitude,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Comentarios
                      BadgeWidget(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionTitle('Comentarios', size: 16),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  itemCount: 10,
                                  itemBuilder: (context, index) =>
                                      CommentCardWidget(
                                    userName: 'Camilo',
                                    userCountry: 'Colombia',
                                    rating: 4.5,
                                    comment: 'fasdfadf',
                                    timeAgo: 'Hoy',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EntityDetailBody — contenido principal cuando los datos están disponibles
// ─────────────────────────────────────────────────────────────────────────────

class _EntityDetailBody extends StatelessWidget {
  final dynamic entity;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _EntityDetailBody({
    required this.entity,
    required this.onDelete,
    required this.onEdit,
    required this.onBack,
    required this.onRetry,
  });

  static const _primaryGreen = Color(0xFF1B4332);
  static const _accentGreen = Color(0xFF2D6A4F);
  static const _actionGreen = Color(0xFF059669);
  static const _lightGreen = Color(0xFFD1FAE5);
  static const _textDark = Color(0xFF111827);
  static const _textMid = Color(0xFF4B5563);
  static const _textLight = Color(0xFF9CA3AF);
  static const _dividerColor = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildContent()),
      ],
    );
  }

  // ── Contenido scrollable ───────────────────────────────────────────────────
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescriptionAndContact(),
          const SizedBox(height: 32),
          _buildMapAndComments(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDescriptionAndContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Descripción
        const _SectionTitle('Descripción'),
        const SizedBox(height: 12),
        Text(
          entity.description.isEmpty
              ? 'Descripción no disponible'
              : entity.description,
          style: const TextStyle(
            fontSize: 15,
            color: _textMid,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 12),
        // Contacto
        _ContactTile(
          icon: Icons.location_on_outlined,
          iconColor: const Color(0xFF059669),
          iconBg: const Color(0xFFD1FAE5),
          label: 'Dirección',
          value: entity.address.isEmpty
              ? 'Dirección no disponible'
              : entity.address,
        ),
        const SizedBox(
          height: 8,
        ),
        _ContactTile(
          icon: Icons.phone_outlined,
          iconColor: const Color(0xFF2563EB),
          iconBg: const Color(0xFFDBEAFE),
          label: 'Teléfono',
          value: entity.phone.isEmpty ? 'Teléfono no disponible' : entity.phone,
        ),
        const SizedBox(
          height: 8,
        ),
        const _ContactTile(
          icon: Icons.email_outlined,
          iconColor: Color(0xFF7C3AED),
          iconBg: Color(0xFFEDE9FE),
          label: 'Correo electrónico',
          value: 'Email no disponible',
        ),
        const SizedBox(
          height: 8,
        ),
        const _ContactTile(
          icon: Icons.schedule_outlined,
          iconColor: Color(0xFFD97706),
          iconBg: Color(0xFFFEF3C7),
          label: 'Horario de atención',
          value: 'Horario no disponible',
        ),
      ],
    );
  }

  Widget _buildMapAndComments() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mapa
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Ubicación'),
              const SizedBox(height: 16),
              _EntityMap(
                latitude: entity.localitation.latitude,
                longitude: entity.localitation.longitude,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Comentarios
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Comentarios'),
                  _ReviewBadge(count: 5),
                ],
              ),
              SizedBox(height: 16),
              // TODO: reemplazar con lista dinámica desde un provider
              _CommentCard(
                initials: 'MA',
                name: 'María Arboleda',
                timeAgo: 'Hace 2 días',
                rating: 5,
                comment:
                    'Excelente labor. La transparencia con la que manejan los recursos y la calidad de los alimentos que entregan es realmente inspiradora para toda la comunidad.',
                avatarColor: _lightGreen,
                initialsColor: _actionGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets de apoyo — candidatos a moverse a archivos propios en widgets/
// ─────────────────────────────────────────────────────────────────────────────

/// Botón circular usado en el AppBar.
class _CircleIconButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;

  const _CircleIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor:
            backgroundColor ?? Colors.white.withValues(alpha: 0.15),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 18),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// Fila individual dentro de _ContactCard.
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 76,
      endIndent: 20,
      color: Color(0xFFF3F4F6),
    );
  }
}

/// Mapa estático con marcador de la entidad.
class _EntityMap extends StatefulWidget {
  final double latitude;
  final double longitude;

  const _EntityMap({required this.latitude, required this.longitude});

  @override
  State<_EntityMap> createState() => _EntityMapState();
}

class _EntityMapState extends State<_EntityMap> {
  final MapController _mapController = MapController();

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(widget.latitude, widget.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 520,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: point,
                initialZoom: 14,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.migraayuda.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
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
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                children: [
                  _ZoomButton(
                    tooltip: 'Acercar',
                    icon: Icons.add,
                    onPressed: _zoomIn,
                  ),
                  const SizedBox(height: 4),
                  _ZoomButton(
                    tooltip: 'Alejar',
                    icon: Icons.remove,
                    onPressed: _zoomOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _ZoomButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 20, color: const Color(0xFF1B4332)),
          ),
        ),
      ),
    );
  }
}

/// Badge con el conteo de reseñas.
class _ReviewBadge extends StatelessWidget {
  final int count;

  const _ReviewBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count reseñas',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF059669),
        ),
      ),
    );
  }
}

/// Tarjeta de comentario de usuario.
class _CommentCard extends StatelessWidget {
  final String initials;
  final String name;
  final String timeAgo;
  final int rating;
  final String comment;
  final Color avatarColor;
  final Color initialsColor;

  const _CommentCard({
    required this.initials,
    required this.name,
    required this.timeAgo,
    required this.rating,
    required this.comment,
    required this.avatarColor,
    required this.initialsColor,
  });

  @override
  Widget build(BuildContext context) {
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
          _Avatar(
              initials: initials, color: avatarColor, textColor: initialsColor),
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
                _StarRow(rating: rating),
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

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  final Color textColor;

  const _Avatar({
    required this.initials,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int rating;

  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 15,
          color: i < rating ? const Color(0xFFFBBF24) : const Color(0xFFE5E7EB),
        ),
      ),
    );
  }
}

/// Título de sección reutilizable.
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorView — pantalla de error con opciones de reintento
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onBack,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
              error,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2D5F4F),
                    side: const BorderSide(color: Color(0xFF2D5F4F), width: 2),
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
                  onPressed: onRetry,
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
    );
  }
}
