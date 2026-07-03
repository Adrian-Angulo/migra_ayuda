import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';

class UsersDatatable extends DataTableSource {
  List<UserModel> listUsers;
  UsersDatatable({required this.listUsers});

  @override
  DataRow? getRow(int index) {
    if (index >= listUsers.length) return null;
    final user = listUsers[index];
    return  DataRow2(cells: [
      DataCell(Text(user.name)),
      DataCell(Text(user.email)),
      DataCell(Text(user.originCountry ?? 'No definido')),
    ]);
  }

  @override

  bool get isRowCountApproximate => false;

  @override
  int get rowCount => listUsers.length;

  @override
  int get selectedRowCount => 0;
}
