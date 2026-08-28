import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/entity_seleted_details.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/homeCardWidgets/entity_card_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/homeCardWidgets/text_result.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class ListEntitesHome extends ConsumerWidget {
  const ListEntitesHome({
    super.key,
    required this.sheetController,
  });

  final DraggableScrollableController sheetController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String selectedFiltro = ref.watch(filterProvider);
    final listEntity = ref.watch(getAllEntitiesProvider);
    final map = ref.watch(mapProvider);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, spreadRadius: 1),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (map.selectEntity == null)
                  listEntity.when(
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
                                  //entitiesEmpyList
                                  '${l10n.entitesEmpyList} ${getServicel10n(selectedFiltro, context)}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          spacing: 5,
                          key: const ValueKey('lista'),
                          children: [
                            const TextResult(),
                            ...List.generate(
                              data.length,
                              (index) => EntityCardWidget(entity: data[index]),
                            ),
                          ],
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
                                  //entitesError
                                  l10n.entitesError,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ],
                            ),
                          ),
                      loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ))
                else
                  EntitySeletedDetails(map: map, controllerD: sheetController),
              ],
            ));
      },
    );
  }
}
