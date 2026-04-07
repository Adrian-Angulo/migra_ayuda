import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/repositories/entity_repository.dart';

class RegisterEntityUsecase {
  final EntityRepository repository;

  RegisterEntityUsecase({required this.repository});

  Future<Either<String, Unit>> call(
    EntityEntity entity,
    Uint8List imagenBytes,
    String fileName,
  ) async {
    return await repository.registerEntity(
      entity: entity,
      imagenBytes: imagenBytes,
      fileName: fileName,
    );
  }
}
