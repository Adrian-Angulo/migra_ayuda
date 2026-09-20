import 'package:migra_ayuda/core/errors/failure.dart';

abstract class ReviewFailure extends Failure {
  const ReviewFailure({required super.message, super.code});
}

class ReviewNotFoundFailure extends ReviewFailure {
  const ReviewNotFoundFailure({
    super.message = 'Reseña no encontrada',
    super.code = 'review-not-found',
  });
}

class ReviewCreationFailedFailure extends ReviewFailure {
  const ReviewCreationFailedFailure({
    super.message = 'Error al crear la reseña',
    super.code = 'review-creation-failed',
  });
}

class ReviewUpdateFailedFailure extends ReviewFailure {
  const ReviewUpdateFailedFailure({
    super.message = 'Error al actualizar la reseña',
    super.code = 'review-update-failed',
  });
}

class ReviewDeletionFailedFailure extends ReviewFailure {
  const ReviewDeletionFailedFailure({
    super.message = 'Error al eliminar la reseña',
    super.code = 'review-deletion-failed',
  });
}

class ReviewFetchFailedFailure extends ReviewFailure {
  const ReviewFetchFailedFailure({
    super.message = 'Error al obtener las reseñas',
    super.code = 'review-fetch-failed',
  });
}

class ReviewSyncFailedFailure extends ReviewFailure {
  const ReviewSyncFailedFailure({
    super.message = 'Error al sincronizar las reseñas',
    super.code = 'review-sync-failed',
  });
}

class GenericReviewFailure extends ReviewFailure {
  const GenericReviewFailure({
    required super.message,
    super.code,
  });
}
