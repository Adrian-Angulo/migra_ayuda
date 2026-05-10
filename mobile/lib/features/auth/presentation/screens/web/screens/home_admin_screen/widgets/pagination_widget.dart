import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page $currentPage of $totalPages',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Row(
          children: [
            // Botón anterior
            IconButton(
              onPressed: currentPage > 1
                  ? () => onPageChanged(currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
              color: Colors.grey.shade700,
              disabledColor: Colors.grey.shade300,
            ),
            const SizedBox(width: 8),
            // Números de página
            ..._buildPageNumbers(),
            const SizedBox(width: 8),
            // Botón siguiente
            IconButton(
              onPressed: currentPage < totalPages
                  ? () => onPageChanged(currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
              color: Colors.grey.shade700,
              disabledColor: Colors.grey.shade300,
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];

    // Mostrar máximo 5 páginas
    int start = (currentPage - 2).clamp(1, totalPages);
    int end = (start + 4).clamp(1, totalPages);

    // Ajustar start si end está al límite
    if (end == totalPages && totalPages > 5) {
      start = (totalPages - 4).clamp(1, totalPages);
    }

    for (int i = start; i <= end; i++) {
      pages.add(
        _PageButton(
          page: i,
          isActive: i == currentPage,
          onTap: () => onPageChanged(i),
        ),
      );
      if (i < end) {
        pages.add(const SizedBox(width: 4));
      }
    }

    return pages;
  }
}

class _PageButton extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;

  const _PageButton({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF8C42) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Text(
            page.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
