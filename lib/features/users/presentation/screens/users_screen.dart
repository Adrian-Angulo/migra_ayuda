import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/widgets/tables/build_header_cell.dart';
import 'package:migra_ayuda/core/widgets/tables/build_table.dart';
import 'package:migra_ayuda/core/services/export/export_services.dart';
import 'package:migra_ayuda/core/widgets/web/dasboard_header.dart';
import 'package:migra_ayuda/core/widgets/web/text_fiel_search_web.dart';
import 'package:migra_ayuda/features/users/presentation/providers/datatable_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/widgets/export_button.dart';
import 'package:migra_ayuda/features/users/presentation/widgets/users_datatable_source.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingL,
        vertical: UIConstants.spacingL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con el título
          const HeaderWeb(
            title: "Gestión de usuarios",
            subTitle: "Gestiona los usuarios registrados en el sistema",
          ),
          const SizedBox(height: UIConstants.spacingM),

          // Barra de búsqueda y acciones adaptable
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextFielSearchWeb(
                    onChanged: (String value) {
                      ref.read(queryUserProvider.notifier).state =
                          value.toLowerCase().trim();
                    },
                    hintText: 'Buscar usuario...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ExportButton(
                label: 'Exportar',
                onPressed: () {
                  ExportService.exportUsers(usersState.value ?? []);
                },
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingM),

          // Sección donde se muestran los datos de la tabla según el estado
          usersState.when(
            data: (users) {
              final rows = UsersDatatableSource(listUsers: users);

              return BuildTable(
                rows: rows,
                columns: [
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('ID'),
                    fixedWidth: 30,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Nombre'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Correo'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Rol'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Edad'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('País de origen'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('País de destino'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Fecha de registro'),
                    size: ColumnSize.S,
                  ),
                ],
              );
            },
            error: (error, stackTrace) {
              return Text('Error $error');
            },
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        ],
      ),
    );
  }
}
