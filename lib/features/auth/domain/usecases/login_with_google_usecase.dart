import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:migra_ayuda/features/users/domain/repository/user_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  LoginWithGoogleUseCase(this._authRepository, this._userRepository);

  Future<Migrant> call() async {
    // 1. Autenticar con Google
    final authUser = await _authRepository.authWithGoogle();

    // 2. Verificar o crear perfil de usuario en base de datos (Users)
    Migrant? userProfile = await _userRepository.getUserById(authUser.id);
    if (userProfile == null) {
      userProfile = Migrant(
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
      await _userRepository.createUser(userProfile);
    }

    return userProfile;
  }
}

