import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_web_widget.dart';
import 'package:migra_ayuda/core/widgets/web/text_fiel_search_web.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/tabla_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/export_button_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/filter_button.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/table_entities.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/widgets.dart';

class EntitiesScreen extends ConsumerWidget {
  const EntitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seletedService = ref.watch(seletedServiceProvider);

    // Escuchar cambios en el estado del registro
    ref.listen(entitiesCrudProvider, (
      previous,
      next,
    ) {
      if (previous!.isLoading) {
        next.when(
          data: (operation) {
            if (operation == CrudOperation.register) {
              SnackbarWebWidget.success(
                  context, 'Entidad registrada existosamente');
            }
            if (operation == CrudOperation.update) {
              SnackbarWebWidget.success(
                  context, 'Entidad actualizada existosamente');
            }
            if (operation == CrudOperation.delete) {
              SnackbarWebWidget.success(
                  context, 'Entidad eliminada existosamente');
            }
          },
          loading: () {}, // No hacer nada mientras carga
          error: (error, stack) {
            // Error - mostrar mensaje
            SnackbarWebWidget.error(context, 'Error: ${error.toString()}');
          },
        );
      }
    });

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
                    "Entidades",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Gestiona las entidades registradas en el sistema")
                ],
              ),
              AddButtonWidget(
                text: "Registrar entidad",
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => const AddEntityModal());
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
                TextFielSearchWeb(onChanged: (String value) { 
                   ref.read(seletedServiceProvider.notifier).state =
                              value;
                          ref
                              .read(datasourceProvider)
                              .aplicarFiltros("", value);
                 }, hintText: '',),
                Row(
                  children: [
                    SizedBox(
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
          const TableEntities()
        ],
      ),
    );
  }
}
