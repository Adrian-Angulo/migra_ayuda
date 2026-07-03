import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_header_cell.dart';
import 'package:migra_ayuda/features/auth/domain/entites/users_datatable.dart';

class BuildTable extends StatelessWidget {
  const BuildTable({
    super.key,
    required this.rows,
    required this.columns,
  });

  final UsersDatatable rows;
  final List<DataColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16)),
            child: PaginatedDataTable2(
              wrapInCard: false,
              rowsPerPage: 10,
              source: rows,
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
              empty: DataTableUtils.buildEmptyFrame(
                icon: Icons.people_outline_rounded,
                title: 'No hay usuarios registrados',
                subtitle: 'Aún no se han registrado usuarios en el sistema',
              ),
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                top: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              headingRowColor: WidgetStateProperty.all(
                Colors.grey.shade50,
              ),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF374151),
              ),
              dataTextStyle: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
              columns: columns,
            ),
          ),
        ),
      ),
    );
  }
}
