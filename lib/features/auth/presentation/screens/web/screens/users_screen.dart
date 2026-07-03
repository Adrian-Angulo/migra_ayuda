import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_header_cell.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_table.dart';
import 'package:migra_ayuda/features/auth/domain/entites/users_datatable.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/datatable_providers.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/button_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/widgets/register_admin_dialog.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/add_button_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/export_button_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/filter_button.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingL, vertical: UIConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Usuarios",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Gestiona los usuarios registradas en el sistema")
                ],
              ),
              AddButtonWidget(
                text: "Registrar Administrador",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const RegisterAdminDialog();
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(
            height: UIConstants.spacingM,
          ),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 450,
                  child: TextField(
                    onChanged: (value) => ref
                        .read(queryUserProvider.notifier)
                        .state = value.toLowerCase().trim(),
                    decoration: InputDecoration(
                      hintText: 'Usuario ...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          // Limpiar búsqueda
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color(0xFF2563EB),
                          width: 2,
                        ),
                      ),
                      hoverColor: Colors.transparent,
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: FilterButton(
                        label: 'Filtrar',
                        value: 'Todos',
                        options: const [
                          'Todos',
                          'Migrante',
                          'Administrador',
                        ],
                        onChanged: (String? value) {},
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingM),
                    ExportButtonWidget(label: 'Exportar', onPressed: () {})
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: UIConstants.spacingM,
          ),
          usersState.when(
            data: (users) {
              final rows = UsersDatatable(listUsers: users);

              return BuildTable(
                rows: rows,
                columns: [
                  DataColumn2(
                      label: DataTableUtils.buildHeaderCell('ID'),
                      fixedWidth: 30),
                  DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Nombre'),
                      size: ColumnSize.M),
                  DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Correo'),
                      size: ColumnSize.L),
                  DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Rol'),
                      size: ColumnSize.S),
                  DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Edad'),
                      size: ColumnSize.S),
                  DataColumn2(
                      label: DataTableUtils.buildHeaderCell('País de origen'),
                      size: ColumnSize.M),
                  DataColumn2(
                      label: DataTableUtils.buildHeaderCell('País de destino'),
                      size: ColumnSize.M),
                  DataColumn2(
                      label:
                          DataTableUtils.buildHeaderCell('Fecha de registro'),
                      size: ColumnSize.S),
                ],
              );
            },
            error: (error, stackTrace) {
              return Text('Error $error');
            },
            loading: () {
              return const Text('Cargando...');
            },
          )
        ],
      ),
    );
  }
}

