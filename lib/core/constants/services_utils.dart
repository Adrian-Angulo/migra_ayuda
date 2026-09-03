import 'package:flutter/material.dart';

final services = [
  'Todos',
  'Asesoría Jurídica',
  'Atención Médica',
  'Apoyo Alimentario',
  'Hospedaje Temporal',
  'Inserción Laboral',
  'Movilidad y Transporte'
];

MaterialColor getServiceColor(String service) {
  switch (service.toLowerCase()) {
    case 'asesoría jurídica':
      return Colors.blue;
    case 'atención médica':
      return Colors.green;
    case 'apoyo alimentario':
      return Colors.orange;
    case 'hospedaje temporal':
      return Colors.brown;
    case 'inserción laboral':
      return Colors.purple;
    case 'movilidad y transporte':
      return Colors.teal;
    default:
      return Colors.grey;
  }
}

IconData getServiceIcon(String service) {
  switch (service.toLowerCase()) {
    case 'asesoría jurídica':
      return Icons.gavel;
    case 'atención médica':
      return Icons.local_hospital;
    case 'apoyo alimentario':
      return Icons.restaurant;
    case 'hospedaje temporal':
      return Icons.home;
    case 'inserción laboral':
      return Icons.work;
    case 'movilidad y transporte':
      return Icons.directions_bus;
    default:
      return Icons.category;
  }
}
