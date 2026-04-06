import 'package:flutter/material.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/search_bar_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/entity_card_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/add_button_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/add_entity_modal.dart';

class EntitiesScreen extends StatefulWidget {
  const EntitiesScreen({super.key});

  @override
  State<EntitiesScreen> createState() => _EntitiesScreenState();
}

class _EntitiesScreenState extends State<EntitiesScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Datos de ejemplo
  final List<Map<String, dynamic>> entities = [
    {
      'name': 'Cruz Roja',
      'address': 'Calle 45 #12-30',
      'phone': '+57 3201234567',
      'category': 'Salud',
      'status': 'Verificada',
    },
    {
      'name': 'Banco de Alimentos',
      'address': 'Carrera 10 #23-15',
      'phone': '+57 3109876543',
      'category': 'Alimentación',
      'status': 'Verificada',
    },
    {
      'name': 'Fundación Movilidad',
      'address': 'Av. El Dorado #68-50',
      'phone': '+57 3154567890',
      'category': 'Transporte',
      'status': 'Pendiente',
    },
    {
      'name': 'Hogar Refugio Esperanza',
      'address': 'Calle 80 #55-20',
      'phone': '+57 3187654321',
      'category': 'Alojamiento',
      'status': 'Verificada',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEntityModal() {
    showDialog(context: context, builder: (context) => const AddEntityModal());
  }

  @override
  Widget build(BuildContext context) {
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
            onChanged: (value) {},
          ),
          const SizedBox(height: 24),

          // Lista de entidades
          ...entities.map(
            (entity) => EntityCardWidget(
              name: entity['name'],
              address: entity['address'],
              phone: entity['phone'],
              category: entity['category'],
              status: entity['status'],
              onEdit: () {
                // TODO: Abrir modal para editar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editar: ${entity['name']}')),
                );
              },
              onDelete: () {
                // TODO: Confirmar y eliminar
                _showDeleteDialog(context, entity['name']);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String entityName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "$entityName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$entityName eliminada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
