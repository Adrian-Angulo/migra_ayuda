import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/entities/domain/repositories/entity_repository.dart';

/// Caso de uso para sincronizar todas las entidades desde Firebase
///
/// Descarga TODAS las entidades de Firebase y las guarda en la base de datos local (Sembast).
class SyncAllEntitiesUsecase {
  final EntityRepository repository;

  SyncAllEntitiesUsecase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// Retorna [Right(Unit)] si la sincronización fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, Unit>> call() async {
    return await repository.syncAllFromFirebase();
  }
}
