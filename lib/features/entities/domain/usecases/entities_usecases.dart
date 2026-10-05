import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_mobile_repository.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_web_repository.dart';

class RegisterEntityUseCase {
  final EntityWebRepository repository;

  RegisterEntityUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required EntityEntity entity,
    required Uint8List imagenBytes,
    required String fileName,
  }) {
    return repository.registerEntity(
      entity: entity,
      imagenBytes: imagenBytes,
      fileName: fileName,
    );
  }
}

class UpdateEntityUseCase {
  final EntityWebRepository repository;

  UpdateEntityUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  }) {
    return repository.updateEntity(
      entity: entity,
      imagenBytes: imagenBytes,
      fileName: fileName,
    );
  }
}

class DeleteEntityUseCase {
  final EntityWebRepository repository;

  DeleteEntityUseCase(this.repository);

  Future<Either<Failure, void>> call(String entityId) {
    return repository.deleteEntity(entityId);
  }
}

class GetAllEntities2StreamUseCase {
  final EntityWebRepository repository;

  GetAllEntities2StreamUseCase(this.repository);

  Stream<List<EntityEntity>> call() {
    return repository.getAllEntites2();
  }
}



class GetEntityByIdUseCase {
  final EntityWebRepository repository;

  GetEntityByIdUseCase(this.repository);

  Future<Either<Failure, EntityEntity>> call(String id) {
    return repository.getEntityById(id);
  }
}

// Casos de uso para mobile

class GetAllEntitiesUseCase {
  final EntityMobileRepository repository;

  GetAllEntitiesUseCase(this.repository);

  Future<Either<Failure, List<EntityEntity>>> call() {
    return repository.getAllEntities();
  }
}

class SyncAllFromFirebaseUseCase {
  final EntityMobileRepository repository;

  SyncAllFromFirebaseUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.syncAllFromFirebase();
  }
}
