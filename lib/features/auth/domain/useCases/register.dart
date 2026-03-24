import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

class Register {
  final AuthRepository _repository;

  Register(this._repository);

  Future<void> call(
      {required String name,
      required String lasname,
      required String email,
      required String password,
      required String originCountry,
      required String destinationCountry,
      required int age}) async {
    try {
      await _repository.register(name, lasname, email, password, originCountry,
          destinationCountry, age);
    } catch (e) {
      throw Exception("$e");
    }
  }
}
