import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/place_card.dart';

class ExplorarSheetContent extends StatelessWidget {
  final List<EntityEntity> entities;
  final List<String> filtros;
  final int selectedFiltro;
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;
  final bool isControllerAttached;
  final Future<void> Function() onRefresh;
  final ValueChanged<EntityEntity> onEntityTap;

  const ExplorarSheetContent({
    super.key,
    required this.entities,
    required this.filtros,
    required this.selectedFiltro,
    required this.scrollController,
    required this.sheetController,
    required this.isControllerAttached,
    required this.onRefresh,
    required this.onEntityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SheetHandle(
          sheetController: sheetController,
          isControllerAttached: isControllerAttached,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _EntitiesList(
            entities: entities,
            filtros: filtros,
            selectedFiltro: selectedFiltro,
            scrollController: scrollController,
            onRefresh: onRefresh,
            onEntityTap: onEntityTap,
          ),
        ),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  final DraggableScrollableController sheetController;
  final bool isControllerAttached;

  const _SheetHandle({
    required this.sheetController,
    required this.isControllerAttached,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        if (isControllerAttached && sheetController.isAttached) {
          final screenHeight = MediaQuery.of(context).size.height;
          final delta = details.primaryDelta! / screenHeight;
          final newSize = (sheetController.size - delta).clamp(0.15, 0.85);
          sheetController.jumpTo(newSize);
        }
      },
      child: Column(
        children: [
          Center(
            child: Container(
              width: 60,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12, top: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Servicios cercanos'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (isControllerAttached && sheetController.isAttached) {
                      sheetController.animateTo(
                        0.15,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntitiesList extends StatelessWidget {
  final List<EntityEntity> entities;
  final List<String> filtros;
  final int selectedFiltro;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final ValueChanged<EntityEntity> onEntityTap;

  const _EntitiesList({
    required this.entities,
    required this.filtros,
    required this.selectedFiltro,
    required this.scrollController,
    required this.onRefresh,
    required this.onEntityTap,
  });
  @override
  Widget build(BuildContext context) {
    if (entities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selectedFiltro == 0 ? Icons.inbox : Icons.search_off,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              selectedFiltro == 0
                  ? 'No hay entidades disponibles'
                  : 'No hay resultados para "${filtros[selectedFiltro]}"',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Recargar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scrollController,
        itemCount: entities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final entity = entities[index];
          return PlaceCard(
            entity: entity,
            title: entity.name,
            category: entity.services.isNotEmpty
                ? entity.services[0]
                : 'Sin categoría',
            rating: 3.0,
            isOpen: true,
            onTap: () => onEntityTap(entity),
          );
        },
      ),
    );
  }
}
