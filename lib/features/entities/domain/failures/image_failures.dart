import 'package:migra_ayuda/core/errors/failure.dart';

abstract class ImageFailure extends Failure {
  const ImageFailure({required super.message, super.code});
}

class ImageUploadFailure extends ImageFailure {
  const ImageUploadFailure({
    super.message = 'Error al subir la imagen',
    super.code = 'image-upload-failed',
  });
}

class ImageDeleteFailure extends ImageFailure {
  const ImageDeleteFailure({
    super.message = 'Error al eliminar la imagen',
    super.code = 'image-delete-failed',
  });
}

class ImageUnexpectedFailure extends ImageFailure {
  const ImageUnexpectedFailure({
    super.message = 'Ocurrió un error inesperado',
    super.code = 'image-unexpected-failure',
  });
}