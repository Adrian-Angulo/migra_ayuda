
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/action_buttons.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/rating_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/service_chip.dart';

class EntityDataSource extends DataTableSource {
  List<EntityEntity> entities = [];
  List<EntityEntity> _entitiesFiltradas = [];
  final Function(EntityEntity)? onRowSelected;

  EntityDataSource({
    this.onRowSelected,
  });

  void aplicarFiltros(String busqueda, String? servicioSeleccionado) {
    _entitiesFiltradas = entities.where((enty) {
      final coincideTexto =
          enty.name.toLowerCase().contains(busqueda.toLowerCase());

      final coincideServicio = servicioSeleccionado == null ||
          servicioSeleccionado == 'Todos' ||
          enty.services.contains(servicioSeleccionado);

      return coincideTexto && coincideServicio;
    }).toList();

    notifyListeners();
  }

  void actualizarDatos(List<EntityEntity> entitiesNew) {
    entities = entitiesNew;
    _entitiesFiltradas = entities;
    notifyListeners();
  }

  void refrescar() {
    _entitiesFiltradas = entities;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _entitiesFiltradas.length) return null;
    final entity = _entitiesFiltradas[index];
    return DataRow2.byIndex(
      index: index,
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
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
        DataCell(
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entity.address,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: entity.services
                .map((service) => ServiceChip(service: service))
                .toList(),
          ),
        ),
        DataCell(
          Center(
              child: RatingWidget(
            entity: entity,
          )),
        ),
        DataCell(
          ActionButtons(
            entity: entity,
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _entitiesFiltradas.length;

  @override
  int get selectedRowCount => 0;

  // SOLID: Dependency Inversion - Función genérica que acepta cualquier tipo comparable
  void ordenar<T>(
    Comparable<T> Function(EntityEntity e) fnObtenerValor,
    bool ascendiente,
  ) {
    _entitiesFiltradas.sort((a, b) {
      final valorA = fnObtenerValor(a);
      final valorB = fnObtenerValor(b);
      return ascendiente
          ? Comparable.compare(valorA, valorB)
          : Comparable.compare(valorB, valorA);
    });
    notifyListeners();
  }
}