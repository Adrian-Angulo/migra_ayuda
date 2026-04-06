import 'package:flutter/material.dart';

class TableHeaderWidget extends StatelessWidget {
  final List<TableHeaderColumn> columns;

  const TableHeaderWidget({super.key, required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: columns.map((column) {
          return Expanded(
            flex: column.flex,
            child: Text(
              column.title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
                letterSpacing: 0.8,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TableHeaderColumn {
  final String title;
  final int flex;

  const TableHeaderColumn({required this.title, required this.flex});
}
