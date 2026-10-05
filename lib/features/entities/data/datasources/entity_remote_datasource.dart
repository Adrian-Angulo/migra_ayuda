// data/datasources/entidad_remote_datasource.dart

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:migra_ayuda/features/entities/data/datasources/image_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';

class EntityRemoteDataSource {
  final FirebaseFirestore _firestore;
  final ImageRemoteDatasource _imageDatasource = ImageRemoteDatasource();

  EntityRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> registerEntity({
    required EntityModels entityModel,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final String imagenUrl = await _imageDatasource.uploadImage(
          bytes: imageBytes, fileName: fileName);

      final entidadConImagen =
          entityModel.copyWith(id: '', imageUrl: imagenUrl);

      final docRef =
          await _firestore.collection('entities').add(entidadConImagen.toMap());

      await docRef.update({'id': docRef.id});
    } catch (e) {
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
      if (imageBytes != null && fileName != null) {
        imagenUrl = await _imageDatasource.uploadImage(
            bytes: imageBytes, fileName: fileName);
      }

      final entidadActualizada = entityModel.copyWith(imageUrl: imagenUrl);
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
