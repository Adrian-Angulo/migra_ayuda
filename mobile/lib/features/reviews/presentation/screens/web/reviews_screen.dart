import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/tabla_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/export_button_widget.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seletedService = ref.watch(seletedServiceProvider);

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
                    "Reseñas",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Gestiona las valoraciones de los usuarios")
                ],
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
                  width: 400,
                  child: TextField(
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      hintText: 'Buscar reseñas...',
                      prefixIcon: const Icon(Icons.search,
                          size: 20, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: ColorConstants.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      hintStyle:
                          TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ),
                ),
                Row(
                  children: [
                    /* SizedBox(
                      width: 150,
                      child: FilterButton(
                        label: 'Filtrar',
                        value: seletedService,
                        options: services,
                        onChanged: (String? value) {
                          ref.read(seletedServiceProvider.notifier).state =
                              value ?? services[0];
                          ref
                              .read(datasourceProvider)
                              .aplicarFiltros("", value);
                        },
                      ),
                    ), */
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
          /* const TableEntities() */
        ],
      ),
    );
  }
}
