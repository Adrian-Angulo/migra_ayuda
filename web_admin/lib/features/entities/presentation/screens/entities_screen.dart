import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/providers/entity_detail_notifier.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/providers/get_all_entites_notifier.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/providers/delete_entity_notifier.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/edit_entity_modal.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/search_bar_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/entity_card_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/add_button_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/add_entity_modal.dart';

class EntitiesScreen extends ConsumerStatefulWidget {
  const EntitiesScreen({super.key});

  @override
  ConsumerState<EntitiesScreen> createState() => _EntitiesScreenState();
}

class _EntitiesScreenState extends ConsumerState<EntitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EntityEntity> _filterEntities(List<EntityEntity> entities) {
    if (_searchQuery.trim().isEmpty) {
      return entities;
    }

    final query = _searchQuery.toLowerCase().trim();

    return entities.where((entity) {
      final nameMatch = entity.name.toLowerCase().contains(query);
      final addressMatch = entity.address.toLowerCase().contains(query);
      final servicesMatch = entity.services.any(
        (service) => service.toLowerCase().contains(query),
      );

      return nameMatch || addressMatch || servicesMatch;
    }).toList();
  }

  void _showAddEntityModal() {
    showDialog(
      context: context,
      builder: (context) => const AddEntityModal(),
    ).then((_) {
      // Recargar la lista después de cerrar el modal
      ref.read(getAllEntitiesNotifierProvider.notifier).recargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncEntities = ref.watch(getAllEntitiesNotifierProvider);

    
    ref.listen<AsyncValue<void>>(deleteEntityNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (_) {
          // Éxito - mostrar mensaje y recargar lista
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
          // Recargar la lista
          ref.read(getAllEntitiesNotifierProvider.notifier).recargar();
        },
        loading: () {}, // No hacer nada mientras carga
        error: (error, stack) {
          // Error - mostrar mensaje
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión de Entidades',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Administrar entidades colaboradoras',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              AddButtonWidget(
                text: 'Nueva Entidad',
                onPressed: _showAddEntityModal,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Barra de búsqueda
          Row(
            children: [
              Expanded(
                child: SearchBarWidget(
                  hintText: 'Buscar por nombre, dirección o servicio...',
                  controller: _searchController,
                  onChanged: (value) {
                    // El setState se maneja en el listener del controller
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            asyncEntities.when(
              data: (entities) {
                final filtered = _filterEntities(entities);
                return 'Total: ${filtered.length} entidad${filtered.length != 1 ? 'es' : ''}';
              },
              loading: () => 'Buscando...',
              error: (_, __) => 'Error',
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF2D5F4F)),
          ),

          const SizedBox(height: 24),

          // Lista de entidades
          asyncEntities.when(
            data: (allEntities) {
              final entities = _filterEntities(allEntities);

              if (allEntities.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay entidades registradas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega una nueva entidad para comenzar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (entities.isEmpty && _searchQuery.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                            children: [
                              const TextSpan(
                                text: 'No hay entidades que coincidan con ',
                              ),
                              TextSpan(
                                text: '"$_searchQuery"',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D5F4F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: () {
                            _searchController.clear();
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpiar búsqueda'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2D5F4F),
                            side: const BorderSide(color: Color(0xFF2D5F4F)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: entities.map((entity) {
                  return EntityCardWidget(
                    name: entity.name,
                    address: entity.address,
                    phone: entity.phone,
                    category: entity.services.isNotEmpty
                        ? entity.services.first
                        : 'Sin categoría',
                    status: 'Verificada',
                    onTap: () {
                      context.go('/dashboard/entities/${entity.id}');
                    },
                    onEdit: () async {
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
                    onDelete: () {
                      _showDeleteDialog(context, entity.name, entity.id);
                    },
                  );
                }).toList(),
              );
            },
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(64),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF2D5F4F)),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando entidades...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(64),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ocurrió un error al cargar las entidades',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(getAllEntitiesNotifierProvider.notifier)
                            .recargar();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5F4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String entityName,
    String entityId,
  ) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        entityName: entityName,
        onConfirm: () {
          ref.read(deleteEntityNotifierProvider.notifier).eliminar(entityId);
        },
      ),
    );
  }
}
