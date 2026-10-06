import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/chart_data.dart';

class Utils {
  static List<ChartData> serie(
    List<String> dias,
    Map<String, Map<String, int>> agrupado,
    String tipo,
  ) {
    return dias
        .map(
          (dia) => ChartData(
            dia,
            (agrupado[dia]?[tipo] ?? 0).toDouble(),
          ),
        )
        .toList();
  }

  static String formatDia(DateTime dt) {
    const meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${dt.day} ${meses[dt.month - 1]}';
  }

  static DateTime? parseCreatedAt(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value).toLocal();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String formatMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null || metadata.isEmpty) return '';
    return metadata.entries.map((e) => '${e.value}').join(', ');
  }
}
