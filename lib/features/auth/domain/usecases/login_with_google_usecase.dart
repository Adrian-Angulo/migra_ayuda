import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  LoginWithGoogleUseCase(this._authRepository, this._userRepository);

  Future<Either<Failure, Migrant>> call() async {
    // 1. Autenticar con Google
    final authResult = await _authRepository.authWithGoogle();

    return authResult.fold(
      (failure) => Left(failure),
      (authUser) async {
        // 2. Verificar o crear perfil de usuario en base de datos (Users)
        final profileResult = await _userRepository.getUserById(authUser.id);

        return profileResult.fold(
          (userFailure) => Left(userFailure),
          (userProfile) async {
            if (userProfile != null) {
              return Right(userProfile);
            }

            final newProfile = Migrant(
              id: authUser.id,
              name: authUser.displayName ?? 'Usuario',
              email: authUser.email,
              originCountry: '-',
              destinationCountry: '-',
              age: '-',
              role: 'Migrante',
              profileComplete: false,
              createdAt: DateTime.now(),
            );

            final createResult = await _userRepository.createUser(newProfile);

            return createResult.fold(
              (createFailure) => Left(createFailure),
              (_) => Right(newProfile),
            );
          },
        );
      },
    );
  }
}

