import 'package:dartz/dartz.dart';
import 'package:migra_ayuda/features/language/domain/repositories/language_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguajeRepositoryImpl implements LanguageRepository {
  final SharedPreferences prefs;

  LanguajeRepositoryImpl({required this.prefs});

  @override
  Future<Either<String, Unit>> deleteLanguage() {
    // TODO: implement deleteLanguage
    throw UnimplementedError();
  }

  @override
  Future<Either<String, String?>> readLanguage() {
    // TODO: implement readLanguage
    throw UnimplementedError();
  }

  @override
  Future<Either<String, Unit>> saveLanguage() async {
    // TODO: implement readLanguage
    throw UnimplementedError();
  }
}
