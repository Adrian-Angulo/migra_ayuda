import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_header_cell.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entities_datasource.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/tabla_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/providers/entities_provider_web.dart';
class TableEntities extends ConsumerStatefulWidget {
  const TableEntities({super.key});

  @override
  ConsumerState<TableEntities> createState() => _TableEntitiesState();
}

class _TableEntitiesState extends ConsumerState<TableEntities> {
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
                 empty: DataTableUtils.buildEmptyFrame(icon: Icons.business_outlined, title: 'No hay entidades', subtitle: 'No se encontraron entidades registradas'),
                  columns: [
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Nombre'),
                      size: ColumnSize.L,
                      onSort: _ejecutarOrdenamiento,
                    ),
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Dirección'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Servicios'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Valoración'),
                      fixedWidth: 100,
                    ),
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Acciones'),
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
        return DataTableUtils.buildErrorFrame(error.toString());
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
}


