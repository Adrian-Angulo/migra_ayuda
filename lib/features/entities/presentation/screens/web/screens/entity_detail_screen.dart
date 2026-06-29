import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/widgets/badge_widget.dart';
import 'package:migra_ayuda/core/widgets/divider_widget.dart';
import 'package:migra_ayuda/core/widgets/placeholder_image.dart';
import 'package:migra_ayuda/core/widgets/web/button_web_widget.dart';
import 'package:migra_ayuda/core/widgets/web/map_web.dart';
import 'package:migra_ayuda/core/widgets/web/section_title.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/widgets/comment_card_widget.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/delete_entity_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_detail_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/error_screen.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/delete_confirmation_dialog.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/edit_entity_modal.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/rating_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/service_chip.dart';

import 'widgets/contact_title_widget.dart';

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
        error: (error, _) => ErrorScreen(
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
                ButtonWebWidget.text(
                    icon: Icons.arrow_back_ios_new,
                    label: 'Vover',
                    onPressed: () => context.go('/dashboard/entities')),
                const Spacer(),
                ButtonWebWidget.danger(
                    icon: Icons.delete_outline,
                    label: 'Eliminar',
                    onPressed: () {}),
                SizedBox(
                  width: 12,
                ),
                ButtonWebWidget.warning(
                    icon: Icons.edit_outlined,
                    label: 'Editar',
                    onPressed: () {}),
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

                              const SizedBox(height: 8),
                              ContactTitleWidget(
                                icon: Icons.phone_outlined,
                                iconColor: const Color(0xFF2563EB),
                                iconBg: const Color(0xFFDBEAFE),
                                label: 'Teléfono',
                                value: entity.phone.isEmpty
                                    ? 'Teléfono no disponible'
                                    : entity.phone,
                              ),
                              const SizedBox(height: 8),
                              const ContactTitleWidget(
                                icon: Icons.email_outlined,
                                iconColor: Color(0xFF7C3AED),
                                iconBg: Color(0xFFEDE9FE),
                                label: 'Correo electrónico',
                                value: 'Email no disponible',
                              ),
                              const SizedBox(height: 8),
                              const ContactTitleWidget(
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
                              Row(
                                spacing: 10,
                                children: [
                                  const SectionTitle('Ubicación'),
                                  Text(
                                    '(${entity.address})',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SectionTitle('Comentarios', size: 16),
                                  ButtonWebWidget.textBlack(
                                      label: 'Ver mas', onPressed: () {})
                                ],
                              ),
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
// Widgets de apoyo — candidatos a moverse a archivos propios en widgets/
// ─────────────────────────────────────────────────────────────────────────────

/// Fila individual dentro de _ContactCard.
