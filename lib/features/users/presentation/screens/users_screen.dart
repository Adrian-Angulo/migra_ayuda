import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_header_cell.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_table.dart';
import 'package:migra_ayuda/core/widgets/web/text_fiel_search_web.dart';
import 'package:migra_ayuda/features/users/domain/entities/users_datatable.dart';
import 'package:migra_ayuda/features/users/presentation/providers/datatable_providers.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/widgets/register_admin_dialog.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/add_button_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/export_button_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/filter_button.dart';

// Pantalla principal para la gestión de usuarios en la versión web.
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el estado filtrado de los usuarios usando Riverpod
    final usersState = ref.watch(usersFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingL, vertical: UIConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con el título y el botón para registrar administrador
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
                  // Subtítulo descriptivo
                  Text("Gestiona los usuarios registradas en el sistema")
                ],
              ),
              // Botón para abrir el diálogo de registro de administrador
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
          // Barra de búsqueda y acciones (filtrar/exportar)
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Campo de búsqueda básica
                TextFielSearchWeb(
                  onChanged: (String value) {
                    // Cambiamos el filtro de búsqueda con el texto ingresado
                    ref.read(queryUserProvider.notifier).state =
                        value.toLowerCase().trim();
                  },
                  hintText: 'Buscar usuario...',
                ),
                Row(
                  children: [
                    // Botón desplegable para filtro por rol
                    SizedBox(
                      width: 200,
                      child: FilterButton(
                        label: 'Filtrar',
                        value: ref.watch(userRoleFilterProvider),
                        options: const [
                          'Todos',
                          'Migrante',
                          'Admin',
                        ],
                        onChanged: (String? value) {
                          ref.read(userRoleFilterProvider.notifier).state =
                              value ?? 'Todos';
                        },
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingM),
                    // Botón para exportar usuarios
                    ExportButtonWidget(label: 'Exportar', onPressed: () {})
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: UIConstants.spacingM,
          ),
          // Sección donde se muestran los datos de la tabla según el estado
          usersState.when(
            data: (users) {
              // Creamos las filas de la tabla con los usuarios
              final rows = UsersDatatable(listUsers: users);
              
              // Tabla personalizada mostrando los usuarios y sus propiedades
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
            // Mostrar mensaje si ocurre un error al cargar los usuarios
            error: (error, stackTrace) {
              return Text('Error $error');
            },
            // Indicador de carga mientras se cargan los usuarios
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        ],
      ),
    );
  }
}
