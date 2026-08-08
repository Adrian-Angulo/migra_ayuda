import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/action_buttons.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/rating_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/service_chip.dart';

class EntityDatatable extends DataTableSource {
  final List<EntityEntity> listEntities;

  EntityDatatable({required this.listEntities});

  @override
  DataRow? getRow(int index) {
    if (index >= listEntities.length) return null;

    final entity = listEntities[index];

    return DataRow2.byIndex(
      index: index,
      cells: [
        // Nombre
        DataCell(
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(Icons.business, size: 20, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entity.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Dirección
        DataCell(
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entity.address,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Servicios
        DataCell(
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: entity.services
                .take(2)
                .map((s) => ServiceChip(service: s))
                .toList(),
          ),
        ),
        // Valoración
        DataCell(
          Center(child: RatingWidget(entity: entity)),
        ),
        // Acciones
        DataCell(
          ActionButtons(entity: entity),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => listEntities.length;

  @override
  int get selectedRowCount => 0;
}
