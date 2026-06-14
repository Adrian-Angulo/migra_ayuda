import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/drawer/app_drawer.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/filter_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/get_all_entites_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/mapbox_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/homeCardWidgets/filter_container.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/homeCardWidgets/text_result.dart';

import 'widgets/homeCardWidgets/entity_card_widget.dart';

class HomeCardScreen extends StatelessWidget {
  HomeCardScreen({super.key});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.background,
        appBar: AppBar(
          title: const Text("Explorar servicios"),
          actions: [
            IconButton(
              icon: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(
                    Icons.person_rounded,
                    color: ColorConstants.grey200,
                  )),
              onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),
        key: scaffoldKey,
        endDrawer: const AppDrawer(),
        body: const Column(
          children: [
            FilterContainer(),
            Expanded(
              child: MapboxWidget(
                key: ValueKey('mapbox_main'),
              ),
            ),
          ],
        ));
  }
}

class MenuCard extends StatelessWidget {
  const MenuCard({
    super.key,
    required this.lista,
    required this.selectedFiltro,
    required this.ref,
  });

  final AsyncValue<List<EntityEntity>> lista;
  final String selectedFiltro;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //filtros---------------------------------
        const FilterContainer(),
        SizedBox(
          height: 8,
        ),
        //Texto cantidad de entidades----------------------
        const TextResult(),
        const SizedBox(
          height: 12,
        ),
        Expanded(
            child: lista.when(
                data: (data) {
                  if (data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'No se encontraron entidades proveedoras de servicio $selectedFiltro',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => await ref
                        .read(getAllEntitiesNotifierProvider.notifier)
                        .recargar(),
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 12,
                      ),
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final entity = data[index];
                        return EntityCardWidget(entity: entity);
                      },
                    ),
                  );
                },
                error: (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Ocurrió un error al cargar los servicios',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ],
                      ),
                    ),
                loading: () => const Center(
                      child: CircularProgressIndicator(),
                    )))
      ],
    );
  }
}
