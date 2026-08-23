import 'package:animate_do/animate_do.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_header_cell.dart';
import 'package:migra_ayuda/core/dataTable/widgets/build_table.dart';
import 'package:migra_ayuda/core/services/export/export_services.dart';
import 'package:migra_ayuda/core/widgets/web/text_fiel_search_web.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/export_button_widget.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_datatable.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsState = ref.watch(reviewsFilterProvider);

    return FadeIn(
      delay: const Duration(seconds: 1),
      child: Padding(
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
                  'Reseñas',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Gestiona las valoraciones de los usuarios'),
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
                      ref.read(queryReviewProvider.notifier).state =
                          value.toLowerCase().trim();
                      
                    },
                    hintText: 'Buscar por usuario, entidad o país...',
                  ),
                  ExportButtonWidget(label: 'Exportar', onPressed: () {
                    ExportService.exportReviews(reviewsState.value!);
                  }),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
      
            // ── Tabla ─────────────────────────────────────────────────────
            reviewsState.when(
              data: (reviews) {
                final rows = ReviewDatatable(listReviews: reviews);
      
                return BuildTable(
                  rows: rows,
                  emptyIcon: Icons.rate_review_outlined,
                  emptyTitle: 'Sin reseñas registradas',
                  emptySubtitle:
                      'Aún no se han registrado valoraciones en el sistema',
                  columns: [
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('#'),
                      fixedWidth: 50,
                    ),
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Entidad'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Usuario'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('País'),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Valoración'),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Comentario'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: DataTableUtils.buildHeaderCell('Fecha'),
                      size: ColumnSize.S,
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
      ),
    );
  }
}
