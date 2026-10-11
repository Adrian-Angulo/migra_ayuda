import 'package:fpdart/fpdart.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/auth/domain/entities/auth_user.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import '../../../users/domain/repository/user_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, AuthUser?>> call() {
    return _repository.getCurrentUser();
  }
}



class LoginWithEmailUseCase {
  final AuthRepository _repository;

  LoginWithEmailUseCase(this._repository);

  Future<Either<Failure, AuthUser>> call(String email, String password) {
    return _repository.loginWithEmail(email, password);
  }
}

class LoginWithGoogleUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  LoginWithGoogleUseCase(this._authRepository, this._userRepository);

  Future<Either<Failure, Migrant>> call() async {
    
    final authResult = await _authRepository.authWithGoogle();

    return authResult.fold(
      (failure) => Left(failure),
      (authUser) async {
      
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

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}

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

//lib/features/auth/usecases/auth_usecases.dart
class RegisterWithEmailUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  RegisterWithEmailUseCase(this._authRepository, this._userRepository);

  Future<Either<Failure, AuthUser>> call(RegisterUserParams params) async {
    final authResult = await _authRepository.registerWithEmail(
      params.email,
      params.password,
    );

    return authResult.fold(
      (failure) => Left(failure),
      (authUser) async {
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
            
            await _authRepository.deleteCurrentUser();
            return Left(userFailure);
          },
          (_) async {
           
            await _authRepository.logout();
            return Right(authUser);
          },
        );
      },
    );
  }
}

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(String email) {
    return _repository.resetPassword(email);
  }
}

class WatchAuthStateUseCase {
  final AuthRepository _repository;

  WatchAuthStateUseCase(this._repository);

  Stream<AuthUser?> call() {
    return _repository.watchAuthState();
  }
}
