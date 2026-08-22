import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/chart_data.dart';

class Utils {

  static Future<LatLng?> getCoordinates(String address) async {
    try {
      final encoded = Uri.encodeComponent(address);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=$encoded&format=json&limit=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'MigraAyuda Flutter App',
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return LatLng(
            double.parse(data[0]['lat']),
            double.parse(data[0]['lon']),
          );
        }
      }
      return null;
    } catch (e, s) {
      debugPrint('ERROR: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  static  List<ChartData> serie(
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
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
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
}