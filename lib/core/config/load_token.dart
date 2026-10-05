import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class LoadEnv {
  static String? _cachedToken;

  static Future<String> getMapboxToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken!;
    }
    if (!dotenv.isInitialized) {
      await dotenv.load(fileName: '.env');
    }
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    _cachedToken = token;
    return token;
  }

  static Future<void> setup() async {
    await dotenv.load(fileName: '.env');
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];

    if (token == null || token.isEmpty) {
      throw Exception('MAPBOX_ACCESS_TOKEN is not se in .env file');
    }
    _cachedToken = token;
    MapboxOptions.setAccessToken(token);
  }
}
