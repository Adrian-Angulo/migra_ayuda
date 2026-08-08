import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/utils/format/time_formatter.dart';
import 'package:migra_ayuda/features/userActivity/domain/entities/user_activity.dart';

class UserActivityDatatable extends DataTableSource {
  final List<UserActivity> listActivities;

  UserActivityDatatable({required this.listActivities});

  @override
  DataRow? getRow(int index) {
    if (index >= listActivities.length) return null;

    final activity = listActivities[index];

    return DataRow2.byIndex(
      index: index,
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(activity.nombre)),
        DataCell(Text(activity.correo)),
        DataCell(Text(activity.pais)),
        DataCell(_buildAccionChip(activity.accion)),
        DataCell(
          activity.metadata != null && activity.metadata!.isNotEmpty
              ? Text(
                  activity.metadata!.entries
                      .map((e) => '${e.value}')
                      .join(', '),
                )
              : const Text('—'),
        ),
        DataCell(Text(TimeFormatter.formatShortDate(activity.createdAt))),
      ],
    );
  }

  Widget _buildAccionChip(String accion) {
    final (color, icon) = switch (accion) {
      'login' => (Colors.green, Icons.login_rounded),
      'logout' => (Colors.orange, Icons.logout_rounded),
      'seeDetailsEntity' => (Colors.blue, Icons.visibility_rounded),
      'goToEntity' => (Colors.purple, Icons.open_in_new_rounded),
      _ => (Colors.grey, Icons.circle_outlined),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            accion,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => listActivities.length;

  @override
  int get selectedRowCount => 0;
}
