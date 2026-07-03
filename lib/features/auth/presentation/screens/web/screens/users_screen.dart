import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/features/auth/domain/entites/users_datatable.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/datatable_providers.dart';
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Entidades",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Gestiona las entidades registradas en el sistema")
                ],
              ),
              AddButtonWidget(text: "Registrar entidad"),
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
                    onChanged: (value) => ref.read(queryUserProvider.notifier).state = value.toLowerCase().trim(),
                    decoration: InputDecoration(
                      hintText: 'Buscar entidad...',
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
                      width: 150,
                      child: FilterButton(
                        label: 'Filtrar',
                        value: 'Activo',
                        options: const [
                          'Todos',
                          'Activo',
                          'Inactivo',
                          'Pendiente'
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
              final datos = UsersDatatable(listUsers: users);
              if (users.isNotEmpty) {
                return Expanded(
                  child: PaginatedDataTable2(
                      border: TableBorder.all(width: 1),
                      minWidth: 600,
                      rowsPerPage: 10,
                      columns: const [
                        DataColumn2(label: Text('Nombre'), size: ColumnSize.M),
                        DataColumn2(label: Text('Correo'), size: ColumnSize.L),
                        DataColumn2(label: Text('Origen'), size: ColumnSize.M),
                      ],
                      source: datos),
                );
              } else {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay usuarios registrados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aún no se han registrado usuarios en el sistema.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
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
