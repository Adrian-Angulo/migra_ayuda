import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/category_selector.dart';

class ExplorarHeader extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<String> filtros;
  final int selectedFiltro;
  final bool hasNewData;
  final VoidCallback onRefresh;
  final ValueChanged<int> onFilterSelected;

  const ExplorarHeader({
    super.key,
    required this.scaffoldKey,
    required this.filtros,
    required this.selectedFiltro,
    required this.hasNewData,
    required this.onRefresh,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '¿Qué necesitas hoy?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 24),
                tooltip: 'Actualizar servicios',
                onPressed: onRefresh,
              ),
              IconButton(
                icon: const Icon(Icons.menu, size: 30),
                onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
        ),
        CategorySelector(
          items: filtros,
          selectedIndex: selectedFiltro,
          onSelected: onFilterSelected,
        ),
        if (hasNewData) _NewDataBanner(onRefresh: onRefresh),
      ],
    );
  }
}

class _NewDataBanner extends StatelessWidget {
  final VoidCallback onRefresh;

  const _NewDataBanner({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRefresh,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.teal[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: Colors.teal[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nuevos servicios disponibles',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.teal[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: onRefresh,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Actualizar',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.teal[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
