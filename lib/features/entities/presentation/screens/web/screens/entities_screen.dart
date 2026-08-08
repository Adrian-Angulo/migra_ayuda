import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_header_cell.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_table.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_web_widget.dart';
import 'package:migra_ayuda/core/widgets/web/text_fiel_search_web.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_datatable.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/tabla_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/export_button_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/filter_button.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/widgets.dart';

class EntitiesScreen extends ConsumerStatefulWidget {
  const EntitiesScreen({super.key});

  @override
  ConsumerState<EntitiesScreen> createState() => _EntitiesScreenState();
}

class _EntitiesScreenState extends ConsumerState<EntitiesScreen> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    ref.read(entitySortColumnProvider.notifier).state = columnIndex;
    ref.read(entitySortAscendingProvider.notifier).state = ascending;
  }

  @override
  Widget build(BuildContext context) {
    final entitiesState = ref.watch(entitiesFilterProvider);
    final selectedService = ref.watch(selectedServiceFilterProvider);

    // Snackbar de feedback para operaciones CRUD
    ref.listen<AsyncValue<CrudOperation>>(entitiesCrudProvider,
        (previous, next) {
      if (previous?.isLoading == true && !next.isLoading) {
        next.when(
          data: (op) {
            if (op == CrudOperation.register) {
              SnackbarWebWidget.success(
                  context, 'Entidad registrada exitosamente');
            } else if (op == CrudOperation.update) {
              SnackbarWebWidget.success(
                  context, 'Entidad actualizada exitosamente');
            } else if (op == CrudOperation.delete) {
              SnackbarWebWidget.success(
                  context, 'Entidad eliminada exitosamente');
            }
          },
          loading: () {},
          error: (error, _) =>
              SnackbarWebWidget.error(context, 'Error: $error'),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingL,
        vertical: UIConstants.spacingL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entidades',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Gestiona las entidades registradas en el sistema'),
                ],
              ),
              AddButtonWidget(
                text: 'Registrar entidad',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddEntityModal(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingM),

          // ── Barra de búsqueda + filtro + exportar ─────────────────────
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextFielSearchWeb(
                  onChanged: (String value) {
                    ref.read(queryEntityProvider.notifier).state =
                        value.toLowerCase().trim();
                  },
                  hintText: 'Buscar por nombre o dirección...',
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: FilterButton(
                        label: 'Filtrar',
                        value: selectedService,
                        options: services,
                        onChanged: (String? value) {
                          ref
                              .read(selectedServiceFilterProvider.notifier)
                              .state = value ?? services[0];
                        },
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingM),
                    ExportButtonWidget(label: 'Exportar', onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),

          // ── Tabla ─────────────────────────────────────────────────────
          entitiesState.when(
            data: (entities) {
              final rows = EntityDatatable(listEntities: entities);

              return BuildTable(
                rows: rows,
                emptyIcon: Icons.business_outlined,
                emptyTitle: 'No hay entidades',
                emptySubtitle:
                    'No se encontraron entidades registradas en el sistema',
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Nombre'),
                    size: ColumnSize.L,
                    onSort: _onSort,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Dirección'),
                    size: ColumnSize.L,
                    onSort: _onSort,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Servicios'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Valoración'),
                    fixedWidth: 100,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Acciones'),
                    fixedWidth: 150,
                  ),
                ],
              );
            },
            error: (error, _) => Center(child: Text('Error: $error')),
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
