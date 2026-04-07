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

  Future<void> updateEntity({
    required EntityModels entityModel,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      print('🔄 Iniciando actualización de entidad: ${entityModel.name}');

      String imagenUrl = entityModel.imageUrl;

      // Solo subir nueva imagen si se proporcionó
      if (imageBytes != null && fileName != null) {
        print('📸 Subiendo nueva imagen...');
        imagenUrl = await _subirImagenCloudinary(
          bytes: imageBytes,
          fileName: fileName,
        );
      }

      final entidadActualizada = EntityModels(
        id: entityModel.id,
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

      print('💾 Actualizando en Firestore...');
      await _firestore
          .collection('entities')
          .doc(entityModel.id)
          .update(entidadActualizada.toMap());
      print('✅ Entidad actualizada con ID: ${entityModel.id}');
    } catch (e, stackTrace) {
      print('❌ Error en updateEntity: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<EntityModels>> getAllEntities() async {
    try {
      print('📥 Obteniendo todas las entidades...');
      final snapshot = await _firestore
          .collection('entities')
          .orderBy('name')
          .get();

      final entities = snapshot.docs
          .map((doc) => EntityModels.fromMap(doc))
          .toList();

      print('✅ ${entities.length} entidades obtenidas');
      return entities;
    } catch (e, stackTrace) {
      print('❌ Error al obtener entidades: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<EntityModels> getEntityById(String id) async {
    try {
      print('📥 Obteniendo entidad con ID: $id');
      final doc = await _firestore.collection('entities').doc(id).get();

      if (!doc.exists) {
        throw Exception('Entidad no encontrada');
      }

      final entity = EntityModels.fromMap(doc);
      print('✅ Entidad obtenida: ${entity.name}');
      return entity;
    } catch (e, stackTrace) {
      print('❌ Error al obtener entidad: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
