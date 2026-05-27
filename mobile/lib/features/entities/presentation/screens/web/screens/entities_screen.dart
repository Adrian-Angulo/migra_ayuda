import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/constants/constants.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/tabla_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/filter_button.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/tabla.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/widgets.dart';


class EntitiesScreen extends ConsumerWidget {
  const EntitiesScreen({super.key});

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
          Row(
            children: [
              SizedBox(
                width: 400,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      ref
                          .read(datasourceProvider)
                          .aplicarFiltros(value, seletedService);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar por usuario, acción o recurso...',
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      hintStyle:
                          TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: UIConstants.spacingM,
              ),
              SizedBox(
                width: 120,
                child: FilterButton(
                  label: 'Filtrar',
                  value: seletedService,
                  options: services,
                  onChanged: (String? value) {
                    ref.read(seletedServiceProvider.notifier).state =
                        value ?? services[0];
                    ref.read(datasourceProvider).aplicarFiltros("", value);
                  },
                ),
              ),
            ],
          ),
          const Tabla()
        ],
      ),
    );
  }
}
