import 'package:migra_ayuda/core/errors/failure.dart';

abstract class EntityFailure extends Failure {
  const EntityFailure({required super.message, super.code});
}

class EntityNotFoundFailure extends EntityFailure {
  const EntityNotFoundFailure({
    super.message = 'Entidad no encontrada',
    super.code = 'entity-not-found',
  });
}

class EntityCreationFailedFailure extends EntityFailure {
  const EntityCreationFailedFailure({
    super.message = 'Error al registrar la entidad',
    super.code = 'entity-creation-failed',
  });
}

class EntityUpdateFailedFailure extends EntityFailure {
  const EntityUpdateFailedFailure({
    super.message = 'Error al actualizar la entidad',
    super.code = 'entity-update-failed',
  });
}

class EntityDeletionFailedFailure extends EntityFailure {
  const EntityDeletionFailedFailure({
    super.message = 'Error al eliminar la entidad',
    super.code = 'entity-deletion-failed',
  });
}

class EntityFetchFailedFailure extends EntityFailure {
  const EntityFetchFailedFailure({
    super.message = 'Error al obtener las entidades',
    super.code = 'entity-fetch-failed',
  });
}

class EntityImageUploadFailure extends EntityFailure {
  const EntityImageUploadFailure({
    super.message = 'Error al subir la imagen de la entidad',
    super.code = 'entity-image-upload-failed',
  });
}

class GenericEntityFailure extends EntityFailure {
  const GenericEntityFailure({
    required super.message,
    super.code,
  });
}
