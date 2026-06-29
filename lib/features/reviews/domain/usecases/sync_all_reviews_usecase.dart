import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/reviews/domain/repositories/review_repository.dart';

/// Caso de uso para sincronizar todas las reviews desde Firebase
///
/// Descarga TODAS las reviews de Firebase y las guarda en la base de datos local (Sembast).
/// Realiza un merge inteligente con reviews locales pendientes de sincronización.
class SyncAllReviewsUsecase {
  final ReviewRepository repository;

  SyncAllReviewsUsecase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// Retorna [Right(Unit)] si la sincronización fue exitosa
  /// Retorna [Left(String)] con el mensaje de error si falla
  Future<Either<String, Unit>> call() async {
    return await repository.syncAllFromFirebase();
  }
}
