import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/repositories/entity_repository.dart';

class UpdateEntityUsecase {
  final EntityRepository repository;

  UpdateEntityUsecase({required this.repository});

  Future<Either<String, Unit>> call({
    required EntityEntity entity,
    Uint8List? imagenBytes,
    String? fileName,
  }) async {
    return await repository.updateEntity(
      entity: entity,
      imagenBytes: imagenBytes,
      fileName: fileName,
    );
  }
}
