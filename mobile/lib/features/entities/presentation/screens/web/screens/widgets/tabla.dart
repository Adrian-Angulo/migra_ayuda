import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/delete_entity_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/tabla_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/providers/entities_provider_web.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/action_buttons.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/empty_table_state.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/rating_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/service_chip.dart';
import 'package:path/path.dart';

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
    final asyncListEntity = ref.watch(entities2StreamProvider);

    return asyncListEntity.when(
      data: (data) {
        _dataSource.actualizarDatos(data);
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16)),
                child: PaginatedDataTable2(
                  sortColumnIndex: _columnaOrdenadaIndex,
                  sortAscending: _esAscendente,
                  wrapInCard: false,
                  rowsPerPage: 10,
                  source: _dataSource,
                  minWidth: 900,
                  dataRowHeight: 72,
                  headingRowHeight: 56,
                  horizontalMargin: 20,
                  columnSpacing: 24,
                  headingRowDecoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  empty: const EmptyTableState(),
                  columns: [
                    DataColumn2(
                      label: _buildHeaderCell('Nombre'),
                      size: ColumnSize.L,
                      onSort: _ejecutarOrdenamiento,
                    ),
                    DataColumn2(
                      label: _buildHeaderCell('Dirección'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: _buildHeaderCell('Servicios'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: _buildHeaderCell('Valoración'),
                      fixedWidth: 100,
                    ),
                    DataColumn2(
                      label: _buildHeaderCell('Acciones'),
                      fixedWidth: 100,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar las entidades',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () {
        return const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
        letterSpacing: 0.5,
      ),
    );
  }
}

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
        const DataCell(
          Center(child: RatingWidget()),
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
