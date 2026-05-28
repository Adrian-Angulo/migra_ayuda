// data/datasources/entidad_remote_datasource.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:migra_ayuda/core/errors/auth_failures.dart';
import 'package:migra_ayuda/core/errors/failures.dart';
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

/// Excepción personalizada para errores del servidor
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

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
        throw ServerException('Error al subir imagen: ${response.body}');
      }

      final json = jsonDecode(response.body);
      return json['secure_url'];
    } catch (e) {
      throw ServerException('Error al subir imagen: $e');
    }
  }

  Future<void> registerEntity({
    required EntityModels entityModel,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final imagenUrl =
          await _uploadImage(bytes: imageBytes, fileName: fileName);

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
    } catch (e) {
      throw ServerException('Error al registrar entidad: $e');
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
    } catch (e) {
      throw ServerException('Error al actualizar entidad: $e');
    }
  }

  Future<void> deleteEntity(String entityId) async {
    try {
      await _firestore.collection('entities').doc(entityId).delete();
    } catch (e) {
      throw ServerException('Error al eliminar entidad: $e');
    }
  }

  Future<List<EntityModels>> getAllEntities() async {
    try {
      final snapshot =
          await _firestore.collection('entities').orderBy('name').get();

      final entities =
          snapshot.docs.map((doc) => EntityModels.fromMap(doc)).toList();

      return entities;
    } catch (e) {
      throw ServerException('Error al obtener entidades: $e');
    }
  }

  Future<EntityModels> getEntityById(String id) async {
    try {
      final doc = await _firestore.collection('entities').doc(id).get();

      if (!doc.exists) {
        throw ServerException('Entidad no encontrada');
      }

      final entity = EntityModels.fromMap(doc);

      return entity;
    } catch (e) {
      throw ServerException('Error al obtener entidad: $e');
    }
  }

  Stream<Either<String, List<EntityEntity>>> getAllEntities2() {
    return _firestore
        .collection('entities')
        .orderBy('name')
        .snapshots()
        .map((snap) {
      try {
        final orgs =
            snap.docs.map((enty) => EntityModels.fromMap(enty)).toList();
        return Right<String, List<EntityEntity>>(orgs);
      } on FirebaseException catch (e) {
        return Left<String, List<EntityEntity>>(e.toString());
      } catch (e) {
        return Left<String, List<EntityEntity>>(e.toString());
      }
    });
  }
  /* Stream<Either<Failure,<List<EntityEntity>>> getAllEntities2() async {
    return _firestore.collection('entities').orderBy('name').snapshots().map((snap){
      try {
        final orgs = snap.docs.map((enty) => EntityModels.fromMap(enty)).toList();
        
      } catch (e) {
        
      }
    })
  } */
}
