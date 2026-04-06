import 'package:flutter/material.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/section_header_widget.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/filter_button_widget.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/table_header_widget.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/user_table_row_widget.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/widgets/pagination_widget.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  int currentPage = 1;
  final int totalPages = 128;
  final int totalUsers = 248;

  // Datos de ejemplo
  final List<Map<String, dynamic>> users = [
    {
      'name': 'Maria Garcia',
      'email': 'm.garcia@migraayuda.org',
      'originCountry': 'Venezuela',
      'destinationCountry': 'Ecuador',
      'registrationDate': '13/02/2026',
      'age': 23,
    },
    {
      'name': 'Juan Perez',
      'email': 'j.perez@migraayuda.org',
      'originCountry': 'Ecuador',
      'destinationCountry': 'Venezuela',
      'registrationDate': '28/02/2026',
      'age': 28,
    },
    {
      'name': 'Ana Lopez',
      'email': 'a.lopez@migraayuda.org',
      'originCountry': 'Venezuela',
      'destinationCountry': 'Colombia',
      'registrationDate': '1/03/2026',
      'age': 30,
    },
    {
      'name': 'Carlos Ruiz',
      'email': 'c.ruiz@migraayuda.org',
      'originCountry': 'Perú',
      'destinationCountry': 'Colombia',
      'registrationDate': '17/03/2026',
      'age': 26,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const SectionHeaderWidget(
            title: 'Usuarios',
            subtitle:
                'Manage and monitor platform access for all MigraAyuda personnel.',
          ),
          const SizedBox(height: 32),

          // Tabla Container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Filtro y contador
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilterButtonWidget(
                        onPressed: () {
                          // TODO: Abrir filtros
                        },
                      ),
                      Text(
                        'Showing ${users.length} of $totalUsers users',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Table Header
                const TableHeaderWidget(
                  columns: [
                    TableHeaderColumn(title: 'Perfil Usuario', flex: 3),
                    TableHeaderColumn(title: 'País Origen', flex: 2),
                    TableHeaderColumn(title: 'País Destino', flex: 2),
                    TableHeaderColumn(title: 'Fecha Registro', flex: 2),
                    TableHeaderColumn(title: 'Edad', flex: 1),
                  ],
                ),

                // Table Rows
                ...users.map(
                  (user) => UserTableRowWidget(
                    name: user['name'],
                    email: user['email'],
                    originCountry: user['originCountry'],
                    destinationCountry: user['destinationCountry'],
                    registrationDate: user['registrationDate'],
                    age: user['age'],
                  ),
                ),

                // Pagination
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: PaginationWidget(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: (page) {
                      setState(() {
                        currentPage = page;
                      });
                      // TODO: Cargar datos de la página
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
