import 'package:dartz/dartz.dart';

abstract class LanguageRepository {
  Future<Either<String, Unit>> saveLanguage();
  Future<Either<String, String?>> readLanguage();
  Future<Either<String, Unit>> deleteLanguage();
}
