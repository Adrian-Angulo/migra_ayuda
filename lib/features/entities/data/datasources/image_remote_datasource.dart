import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ImageRemoteDatasource {
  static final _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['public_id'] =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Error al subir imagen: ${response.body}');
      }

      final json = jsonDecode(response.body);
      return json['secure_url'];
    } catch (e) {
      throw Exception('Error al subir imagen');
    }
  }
}
