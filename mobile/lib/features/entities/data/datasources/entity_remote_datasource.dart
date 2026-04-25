// data/datasources/entidad_remote_datasource.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';

class EntityRemoteDatasource {
  final FirebaseFirestore _firestore;
  static const _cloudName = "dyprnvoff";
  static const _uploadPreset = "MigraAyuda";

  EntityRemoteDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> _uploadImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
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
  }

  Future<void> registerEntity({
    required EntityModels entityModel,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final imagenUrl = await _uploadImage(bytes: imageBytes, fileName: fileName);

    final entidadConImagen = EntityModels(
      id: '',
      name: entityModel.name,
      description: entityModel.description,
      services: entityModel.services,
      address: entityModel.address,
      localitation: entityModel.localitation,
      phone: entityModel.phone,
      serviceHours: entityModel.serviceHours,
      imageUrl: imagenUrl,
    );

    await _firestore.collection('entities').add(entidadConImagen.toMap());
  }

  Future<void> updateEntity({
    required EntityModels entityModel,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    String imagenUrl = entityModel.imageUrl;

    // Solo subir nueva imagen si se proporcionó
    if (imageBytes != null && fileName != null) {
      imagenUrl = await _uploadImage(bytes: imageBytes, fileName: fileName);
    }

    final entidadActualizada = EntityModels(
      id: entityModel.id,
      name: entityModel.name,
      description: entityModel.description,
      services: entityModel.services,
      address: entityModel.address,
      localitation: entityModel.localitation,
      phone: entityModel.phone,
      serviceHours: entityModel.serviceHours,
      imageUrl: imagenUrl,
    );

    await _firestore
        .collection('entities')
        .doc(entityModel.id)
        .update(entidadActualizada.toMap());
  }

  Future<void> deleteEntity(String entityId) async {
    try {
      await _firestore.collection('entities').doc(entityId).delete();
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<List<EntityModels>> getAllEntities() async {
    final snapshot = await _firestore
        .collection('entities')
        .orderBy('name')
        .get();

    final entities = snapshot.docs
        .map((doc) => EntityModels.fromMap(doc))
        .toList();

    return entities;
  }

  Future<EntityModels> getEntityById(String id) async {
    final doc = await _firestore.collection('entities').doc(id).get();

    if (!doc.exists) {
      throw Exception('Entidad no encontrada');
    }

    final entity = EntityModels.fromMap(doc);

    return entity;
  }
}
