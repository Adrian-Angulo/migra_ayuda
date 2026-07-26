import 'package:flutter/material.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

final services = [
  'Todos',
  'Asesoría Jurídica',
  'Atención Médica',
  'Apoyo Alimentario',
  'Hospedaje Temporal',
  'Inserción Laboral',
  'Movilidad y Transporte'
];

String getServicel10n(String service, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  switch (service.trim()) {
    case 'Todos':
      return l10n.filterStateAll;
    case 'Asesoría Jurídica':
      return l10n.filterStateLegal;
    case 'Atención Médica':
      return l10n.filterStateMedical;
    case 'Apoyo Alimentario':
      return l10n.filterStateFoodSupport;
    case 'Hospedaje Temporal':
      return l10n.filterStateTemporaryLodging;
    case 'Inserción Laboral':
      return l10n.filterStateLaborInsertion;
    case 'Movilidad y Transporte':
      return l10n.filterStateMobility;
    default:
      return 'None';
  }
}

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
