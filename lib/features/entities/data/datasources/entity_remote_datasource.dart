import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migra_ayuda/features/entities/data/datasources/image_remote_datasource.dart';
import 'package:migra_ayuda/features/entities/data/models/entity_models.dart';

class EntityRemoteDataSource {
  final FirebaseFirestore _firestore;
  final ImageRemoteDatasource _imageDatasource;

  EntityRemoteDataSource({
    FirebaseFirestore? firestore,
    ImageRemoteDatasource? imageDatasource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _imageDatasource = imageDatasource ?? ImageRemoteDatasource();

  Future<void> registerEntity({
    required EntityModels entityModel,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final String imagenUrl = await _imageDatasource.uploadImage(
      bytes: imageBytes,
      fileName: fileName,
    );

    final docRef = _firestore.collection('entities').doc();
    final entidadConImagen = entityModel.copyWith(
      id: docRef.id,
      imageUrl: imagenUrl,
    );

    await docRef.set(entidadConImagen.toMap());
  }

  Future<void> updateEntity({
    required EntityModels entityModel,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    String imagenUrl = entityModel.imageUrl;
    if (imageBytes != null && fileName != null) {
      imagenUrl = await _imageDatasource.uploadImage(
        bytes: imageBytes,
        fileName: fileName,
      );
    }

    final entidadActualizada = entityModel.copyWith(imageUrl: imagenUrl);
    await _firestore
        .collection('entities')
        .doc(entityModel.id)
        .update(entidadActualizada.toMap());
  }

  Future<void> deleteEntity(String entityId) async {
    await _firestore.collection('entities').doc(entityId).delete();
  }

  Future<List<EntityModels>> getAllEntities() async {
    final snapshot =
        await _firestore.collection('entities').orderBy('name').get();

    return snapshot.docs
        .map((doc) => EntityModels.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<EntityModels> getEntityById(String id) async {
    final doc = await _firestore.collection('entities').doc(id).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('Entidad no encontrada');
    }

    return EntityModels.fromMap(doc.id, doc.data()!);
  }

  Stream<List<EntityModels>> getAllEntitiesStream() {
    return _firestore.collection('entities').orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((doc) => EntityModels.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
