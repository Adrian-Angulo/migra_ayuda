// data/datasources/entidad_remote_datasource.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';

/// Implementación del datasource remoto usando Firebase
class EntityRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const _cloudName = "dyprnvoff";
  static const _uploadPreset = "MigraAyuda";

  EntityRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> _uploadImage({
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
      throw Exception('Error al subir imagen: $e');
    }
  }

  Future<void> registerEntity({
    required EntityModels entityModel,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      // Subir la imagen a Cloudinary y obtener la URL segura
      final String imagenUrl =
          await _uploadImage(bytes: imageBytes, fileName: fileName);

      // Crear una copia del modelo de entidad con la nueva imagen y sin ID
      final entidadConImagen =
          entityModel.copyWith(id: '', imageUrl: imagenUrl);

      // Añadir a Firestore y obtener la referencia al nuevo documento
      final docRef =
          await _firestore.collection('entities').add(entidadConImagen.toMap());

      // Actualizar el documento con su ID generado automáticamente
      await docRef.update({'id': docRef.id});
    } catch (e, stackTrace) {
      // Imprimir stacktrace para ayudar en la depuración
      debugPrint('Error al registrar entidad: $e');
      debugPrint('Stacktrace: $stackTrace');
      throw 'Ocurrio un error inesperado';
    }
  }

  Future<void> updateEntity({
    required EntityModels entityModel,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      String imagenUrl = entityModel.imageUrl;

      // Solo subir nueva imagen si se proporcionó
      if (imageBytes != null && fileName != null) {
        imagenUrl = await _uploadImage(bytes: imageBytes, fileName: fileName);
      }

      final entidadActualizada = entityModel.copyWith(imageUrl: imagenUrl);
      debugPrint('ID: ${entidadActualizada.id}');
      debugPrint('Nombre: ${entidadActualizada.name}');
      debugPrint('Descripción: ${entidadActualizada.description}');
      debugPrint('Servicios: ${entidadActualizada.services.join(', ')}');
      debugPrint('Dirección: ${entidadActualizada.address}');
      debugPrint(
          'Localización: Latitud: ${entidadActualizada.localitation.latitude}, Longitud: ${entidadActualizada.localitation.longitude}');
      debugPrint('Teléfono: ${entidadActualizada.phone}');
      debugPrint('Imagen URL: ${entidadActualizada.imageUrl}');
      debugPrint('Rating promedio: ${entidadActualizada.averageRating}');
      debugPrint('Total de reseñas: ${entidadActualizada.totalReviews}');
      debugPrint('Horario: ${entidadActualizada.schedule}');

      await _firestore
          .collection('entities')
          .doc(entityModel.id)
          .update(entidadActualizada.toMap());
    } catch (e) {
      debugPrint('Erro en updateEntity: $e');
      throw 'Ocurrio un error inesperado';
    }
  }

  Future<void> deleteEntity(String entityId) async {
    try {
      await _firestore.collection('entities').doc(entityId).delete();
    } catch (e) {
      throw Exception('Error al eliminar entidad: $e');
    }
  }

  Future<List<EntityModels>> getAllEntities() async {
    try {
      final snapshot =
          await _firestore.collection('entities').orderBy('name').get();

      final entities = snapshot.docs
          .map((doc) => EntityModels.fromMap(null, doc.data()))
          .toList();

      return entities;
    } catch (e) {
      throw Exception('Error al obtener entidades: $e');
    }
  }

  Future<EntityModels> getEntityById(String id) async {
    try {
      final doc = await _firestore.collection('entities').doc(id).get();

      if (!doc.exists) {
        throw Exception('Entidad no encontrada');
      }

      final entity = EntityModels.fromMap(null, doc.data()!);

      return entity;
    } catch (e) {
      throw Exception('Error al obtener entidad: $e');
    }
  }

  Stream<List<EntityModels>> getAllEntitiesStream() {
    return _firestore.collection('entities').orderBy('name').snapshots().map(
        (snap) => snap.docs
            .map((doc) => EntityModels.fromMap(null, doc.data()))
            .toList());
  }
}
