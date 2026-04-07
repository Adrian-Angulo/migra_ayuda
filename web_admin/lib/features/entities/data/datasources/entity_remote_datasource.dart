// data/datasources/entidad_remote_datasource.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:migra_ayuda_administracion/features/entities/data/models/entity_models.dart';

class EntityRemoteDatasource {
  final FirebaseFirestore _firestore;
  static const _cloudName = "dyprnvoff";
  static const _uploadPreset = "MigraAyuda";

  EntityRemoteDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> _subirImagenCloudinary({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    // ✅ MultipartRequest funciona correctamente en Flutter Web
    final request = http.MultipartRequest('POST', url);

    request.fields['upload_preset'] = _uploadPreset;
    request.fields['public_id'] =
        '${DateTime.now().millisecondsSinceEpoch}_$fileName';

    // agrega los bytes directamente sin convertir a base64
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
  }

  Future<void> registerEntity({
    required EntityModels entityModel,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      print('🚀 Iniciando registro de entidad: ${entityModel.name}');

      final imagenUrl = await _subirImagenCloudinary(
        bytes: imageBytes,
        fileName: fileName,
      );

      final entidadConImagen = EntityModels(
        id: '',
        name: entityModel.name,
        description: entityModel.description,
        services: entityModel.services,
        address: entityModel.address,
        latitude: entityModel.latitude,
        longitude: entityModel.longitude,
        phone: entityModel.phone,
        serviceHours: entityModel.serviceHours,
        imageUrl: imagenUrl,
      );

      print('💾 Guardando en Firestore...');
      final docRef = await _firestore
          .collection('entities')
          .add(entidadConImagen.toMap());
      print('✅ Entidad guardada con ID: ${docRef.id}');
    } catch (e, stackTrace) {
      print('❌ Error en registerEntity: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
