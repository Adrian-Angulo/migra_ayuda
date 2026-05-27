import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/tabla_providers.dart';

class Tabla extends ConsumerStatefulWidget {
  const Tabla({super.key});

  @override
  ConsumerState<Tabla> createState() => _TablaState();
}

class _TablaState extends ConsumerState<Tabla> {
  // Estados para ordenamientos
  int? _columnaOrdenadaIndex;
  bool _esAscendente = true;
  late EntityDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = ref.read(datasourceProvider);
  }

  void _ejecutarOrdenamiento(int columnIndex, bool ascending) {
    setState(() {
      _columnaOrdenadaIndex = columnIndex;
      _esAscendente = ascending;

      if (columnIndex == 0) {
        _dataSource.ordenar((e) => e.id, ascending);
      } else if (columnIndex == 1) {
        _dataSource.ordenar((e) => e.name, ascending);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncListEntity = ref.watch(entitiesStreamProvider);

    return asyncListEntity.when(
      data: (data) {
        _dataSource.actualizarDatos(data);
        return Expanded(
          child: PaginatedDataTable2(
            sortColumnIndex: _columnaOrdenadaIndex,
            sortAscending: _esAscendente,
            rowsPerPage: 10,
            source: _dataSource,
            minWidth: 600,
            wrapInCard: true,
            empty: const Center(
              child: Text('No se encontraron entidades en el sistema'),
            ),
            columns: [
              DataColumn2(
                label: const Text('ID'),
                fixedWidth: 60,
                onSort: _ejecutarOrdenamiento,
              ),
              DataColumn2(
                label: const Text('Nombre'),
                size: ColumnSize.L,
                onSort: _ejecutarOrdenamiento,
              ),
              const DataColumn2(
                label: Text('Dirección'),
                size: ColumnSize.L,
              ),
              const DataColumn2(
                label: Text('Servicios'),
                size: ColumnSize.M,
              ),
              const DataColumn2(
                label: Text('Valoración'),
                size: ColumnSize.S,
              ),
              const DataColumn2(
                label: Text('Acciones'),
                fixedWidth: 80,
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(error.toString()),
        );
      },
      loading: () {
        return const SafeArea(
            child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

// SOLID: Single Responsibility - Widget solo para mostrar rating
class _RatingWidget extends StatelessWidget {
  const _RatingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: Colors.amber.shade700),
          const SizedBox(width: 4),
          Text(
            '4.5',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class EntityDataSource extends DataTableSource {
  List<EntityEntity> entities = [];
  List<EntityEntity> _entitiesFiltradas = [];

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

  @override
  DataRow? getRow(int index) {
    if (index >= _entitiesFiltradas.length) return null;

    final entity = _entitiesFiltradas[index];

    return DataRow2.byIndex(
      index: index,
      cells: [
        DataCell(Text("${index + 1}")),
        DataCell(Text(entity.name)),
        DataCell(Text(entity.address)),
        DataCell(Text(entity.services.join(', '))),
        const DataCell(_RatingWidget()),
        DataCell(
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
              size: 20,
            ),
            onPressed: () {
              // SOLID: Open/Closed - Permite extensión sin modificar la clase
              _entitiesFiltradas.remove(entity);
              notifyListeners();
            },
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
