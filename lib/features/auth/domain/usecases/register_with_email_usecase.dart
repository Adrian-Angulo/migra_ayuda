import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/auth/domain/entities/auth_user.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';

class RegisterUserParams {
  final String name;
  final String email;
  final String password;
  final String originCountry;
  final String destinationCountry;
  final String age;
  final String role;
  final bool profileComplete;

  const RegisterUserParams({
    required this.name,
    required this.email,
    required this.password,
    this.originCountry = '-',
    this.destinationCountry = '-',
    this.age = '-',
    this.role = 'Migrante',
    this.profileComplete = false,
  });
}

class RegisterWithEmailUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  RegisterWithEmailUseCase(this._authRepository, this._userRepository);

  Future<Either<Failure, AuthUser>> call(RegisterUserParams params) async {
    // 1. Registrar credenciales en Auth
    final authResult = await _authRepository.registerWithEmail(
      params.email,
      params.password,
    );

    return authResult.fold(
      (failure) => Left(failure),
      (authUser) async {
        // 2. Crear el perfil de usuario en base de datos (Users)
        final migrant = Migrant(
          id: authUser.id,
          name: params.name,
          email: params.email,
          originCountry: params.originCountry,
          destinationCountry: params.destinationCountry,
          age: params.age,
          role: params.role,
          profileComplete: params.profileComplete,
          createdAt: DateTime.now(),
        );

        final createResult = await _userRepository.createUser(migrant);

        return createResult.fold(
          (userFailure) async {
            // Rollback: Eliminar usuario en Auth si falla la creación en base de datos
            await _authRepository.deleteCurrentUser();
            return Left(userFailure);
          },
          (_) async {
            // 3. Si es migrante, cerrar sesión para forzar verificación de correo
            if (params.role == 'Migrante') {
              await _authRepository.logout();
            }
            return Right(authUser);
          },
        );
      },
    );
  }
}

