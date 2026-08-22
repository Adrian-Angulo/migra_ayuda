import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_header_cell.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_table.dart';
import 'package:migra_ayuda/core/services/export/export_services.dart';
import 'package:migra_ayuda/core/widgets/web/text_fiel_search_web.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/export_button_widget.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_datatable.dart';
import 'package:migra_ayuda/features/audit/presentation/providers/audit_providers.dart';

class UserActivityWebScreen extends ConsumerWidget {
  const UserActivityWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesState = ref.watch(auditFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingL,
        vertical: UIConstants.spacingL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ────────────────────────────────────────────────
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actividad de usuarios',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Registros de acciones realizadas por los usuarios'),
            ],
          ),
          const SizedBox(height: UIConstants.spacingM),

          // ── Barra de búsqueda + exportar ──────────────────────────────
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextFielSearchWeb(
                  onChanged: (String value) {
                    ref.read(queryAuditProvider.notifier).state =
                        value.toLowerCase().trim();
                  },
                  hintText: 'Buscar por usuario, correo o acción...',
                ),
                ExportButtonWidget(label: 'Exportar', onPressed: () {
                 
                  ExportService.exportActivities(activitiesState.value!);
                }),
              ],
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),

          // ── Tabla ─────────────────────────────────────────────────────
          activitiesState.when(
            data: (activities) {
              final rows = AuditDatatable(listActivities: activities);

              return BuildTable(
                rows: rows,
                emptyIcon: Icons.history_rounded,
                emptyTitle: 'Sin actividad registrada',
                emptySubtitle: 'Aún no se han registrado acciones de usuarios',
                columns: [
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('#'),
                    fixedWidth: 50,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Usuario'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Correo'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('País'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Acción'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Metadata'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: DataTableUtils.buildHeaderCell('Fecha'),
                    size: ColumnSize.M,
                  ),
                ],
              );
            },
            error: (error, stackTrace) => Center(
              child: Text('Error: $error'),
            ),
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
