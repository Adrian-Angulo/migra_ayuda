import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/models/user_model.dart';
import 'package:migra_ayuda/features/auth/data/repositories/auth_repository_imple2.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/auth_with_google.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/complete_google_profile.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/login_user.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/logout.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/register.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/reset_password.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    return AuthRepositoryImple2();
  },
);

final authProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);

final loginUserProvider = Provider<LoginUser>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    return LoginUser(repo);
  },
);

final logoutProvider = Provider<Logout>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    return Logout(repo);
  },
);

final registerProvider = Provider<Register>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    return Register(repo);
  },
);

final authGoogleProvider = Provider<AuthWithGoogle>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    return AuthWithGoogle(repo);
  },
);

final completeGoogleProfileProvider = Provider<CompleteGoogleProfile>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    return CompleteGoogleProfile(repo);
  },
);

final resetPasswordProvider = Provider<ResetPassword>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    return ResetPassword(repo);
  },
);
