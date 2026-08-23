import 'package:animate_do/animate_do.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_header_cell.dart';

class BuildTable extends StatelessWidget {
  const BuildTable({
    super.key,
    required this.rows,
    required this.columns,
    this.emptyIcon = Icons.table_rows_outlined,
    this.emptyTitle = 'No hay datos',
    this.emptySubtitle = 'Aún no se han registrado elementos',
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  final DataTableSource rows;
  final List<DataColumn> columns;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final int? sortColumnIndex;
  final bool sortAscending;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FadeIn(
        child: Card(
          color: Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16)),
              child: PaginatedDataTable2(
                sortColumnIndex: sortColumnIndex,
                sortAscending: sortAscending,
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
                  icon: emptyIcon,
                  title: emptyTitle,
                  subtitle: emptySubtitle,
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
      ),
    );
  }
}
