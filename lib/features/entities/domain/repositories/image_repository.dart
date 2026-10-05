import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/core/errors/failure.dart';

abstract class ImageRepository {
  Future<Either<Failure, String>> uploadImage(Uint8List imageBytes, String fileName);
  Future<Either<Failure, bool>> deleteImage(String imageUrl);
}