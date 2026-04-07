import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    // Escuchar cambios en el estado de eliminación
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
          SearchBarWidget(
            hintText: 'Buscar entidades...',
            controller: _searchController,
            onChanged: (value) {
              // TODO: Implementar búsqueda
            },
          ),
          const SizedBox(height: 24),

          // Lista de entidades
          asyncEntities.when(
            data: (entities) {
              if (entities.isEmpty) {
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
