import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/providers/get_all_entites_notifier.dart';
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
                    onEdit: () {
                      // TODO: Abrir modal para editar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Editar: ${entity.name}')),
                      );
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Text('Confirmar eliminación'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "$entityName"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar eliminación en Firestore
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Text('$entityName eliminada'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Recargar la lista
              ref.read(getAllEntitiesNotifierProvider.notifier).recargar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
