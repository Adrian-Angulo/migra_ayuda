import 'dart:typed_data';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

abstract class EntityRepository {
  Future<void> registerEntity({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  });

  Future<void> updateEntity({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  });

  Future<void> deleteEntity(String entityId);
  Stream<List<EntityEntity>> getAllEntites2();
  Future<List<EntityEntity>> getAllEntities();
  Future<EntityEntity> getEntityById(String id);
  Future<void> syncAllFromFirebase();
}
